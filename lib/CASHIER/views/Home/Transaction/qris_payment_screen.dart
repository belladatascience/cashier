import 'dart:async';

import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cashier/CASHIER/utils/user_data_store.dart';
import 'package:cashier/CASHIER/views/Home/Transaction/payment_success_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class QrisPaymentScreen extends StatefulWidget {
  final int totalAmount;
  final String merchantId;
  final String customerName;
  final String? transactionId;
  final String? cashierName;
  final VoidCallback? onOrderCompleted;

  const QrisPaymentScreen({
    super.key,
    this.totalAmount = 44000,
    this.merchantId = 'BEE-COFFEE-01',
    this.customerName = 'Pelanggan Umum',
    this.transactionId,
    this.cashierName,
    this.onOrderCompleted,
  });

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  late final String _activeTxId;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _qrisSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _walletSubscription;
  bool _isProcessing = false;
  int _walletBalance = 1250000;

  // Dynamic Color Tokens
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorSecondary => AppTheme.instance.secondaryColor;
  Color get colorSecondaryContainer => AppTheme.instance.secondaryContainer;
  Color get colorBackground => AppTheme.instance.backgroundColor;
  Color get colorSurface => AppTheme.instance.backgroundColor;
  Color get colorSurfaceContainerLowest => AppTheme.instance.surfaceColor;
  Color get colorSurfaceContainerLow => AppTheme.instance.surfaceContainerLow;
  Color get colorSurfaceContainerHigh => AppTheme.instance.isDarkMode
      ? const Color(0xFF3B3835)
      : const Color(0xFFE8E8E4);
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _activeTxId = widget.transactionId ??
        '#INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    _createQrisSessionInFirestore();
    _listenToQrisStatus();
    _listenToWalletBalance();
  }

  @override
  void dispose() {
    _qrisSubscription?.cancel();
    _walletSubscription?.cancel();
    super.dispose();
  }

  void _listenToWalletBalance() {
    try {
      _walletSubscription = FirebaseFirestore.instance
          .doc('stores/wallet_info')
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          final bal = doc.data()!['balance'];
          if (bal != null && mounted) {
            setState(() => _walletBalance = (bal as num).toInt());
          }
        }
      }, onError: (e) {
        debugPrint('Firestore wallet listener error: $e');
      });
    } catch (_) {}
  }

  Future<void> _createQrisSessionInFirestore() async {
    try {
      final docId = _activeTxId.replaceAll('#', '').trim();
      final user = FirebaseAuth.instance.currentUser;
      final activeStore = UserDataStore.instance.userDataNotifier.value['storeName'] ?? 'Bella Cafe';

      await FirebaseFirestore.instance.collection('qris_sessions').doc(docId).set({
        'invoiceNumber': _activeTxId,
        'merchantId': widget.merchantId,
        'storeName': activeStore,
        'totalAmount': widget.totalAmount,
        'customerName': widget.customerName,
        'cashierUid': user?.uid ?? 'guest',
        'status': 'waiting_payment',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore QRIS session creation error: $e');
    }
  }

  void _listenToQrisStatus() {
    final docId = _activeTxId.replaceAll('#', '').trim();
    _qrisSubscription = FirebaseFirestore.instance
        .collection('qris_sessions')
        .doc(docId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final status = snapshot.data()!['status'];
        if (status == 'paid' && mounted && !_isProcessing) {
          _handlePayNow();
        }
      }
    });
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _handleTopUp() async {
    final newBalance = _walletBalance + 500000;
    setState(() => _walletBalance = newBalance);

    try {
      await FirebaseFirestore.instance.doc('stores/wallet_info').set({
        'balance': newBalance,
        'lastTopUp': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'cashier',
      }, SetOptions(merge: true));
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Top up saldo merchant berhasil disinkronkan ke Firebase!'),
          backgroundColor: colorSecondary,
        ),
      );
    }
  }

  Future<void> _handlePayNow() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final docId = _activeTxId.replaceAll('#', '').trim();
    final now = DateTime.now();
    final dateStr =
        '${now.day} Aug ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final activeCashier = widget.cashierName ??
        FirebaseAuth.instance.currentUser?.displayName ??
        UserDataStore.instance.userDataNotifier.value['cashierName'] ??
        UserDataStore.instance.userDataNotifier.value['name'] ??
        UserDataStore.instance.userDataNotifier.value['accountName'] ??
        'Bella Gita Asmara';
    final activeStore = UserDataStore.instance.userDataNotifier.value['storeName'] ?? 'Bella Cafe';

    try {
      // 1. Update QRIS session di Cloud Firestore
      await FirebaseFirestore.instance.collection('qris_sessions').doc(docId).set({
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
        'settledAmount': widget.totalAmount,
      }, SetOptions(merge: true));

      // 2. Simpan transaksi resmi di Firestore
      await FirebaseFirestore.instance.collection('transactions').doc(docId).set({
        'invoiceNumber': _activeTxId,
        'dateTime': dateStr,
        'cashierName': activeCashier.toString(),
        'paymentMethod': 'QRIS',
        'customerName': widget.customerName.trim().isNotEmpty
            ? widget.customerName.trim()
            : 'Pelanggan Umum',
        'tableNumber': '-',
        'subtotal': (widget.totalAmount / 1.1).round(),
        'tax': widget.totalAmount - (widget.totalAmount / 1.1).round(),
        'total': widget.totalAmount,
        'status': 'LUNAS',
        'storeName': activeStore.toString(),
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': now.toIso8601String(),
      }, SetOptions(merge: true));

      // 3. Update saldo merchant di Firestore
      await FirebaseFirestore.instance.doc('stores/wallet_info').set({
        'balance': _walletBalance + widget.totalAmount,
        'lastIncome': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error finalizing QRIS transaction in Firestore: $e');
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          totalAmount: widget.totalAmount,
          customerName: widget.customerName.trim().isNotEmpty
              ? widget.customerName.trim()
              : 'Pelanggan Umum',
          transactionId: _activeTxId,
          paymentMethod: 'Digital Wallet (QRIS Cloud)',
          cashierName: activeCashier.toString(),
          onOrderCompleted: widget.onOrderCompleted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          backgroundColor: colorBackground,
          appBar: AppBar(
            backgroundColor: colorBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'BGA Co. Cashier',
              style: GoogleFonts.sourceSerif4(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.cloud_done, color: colorSecondary),
                tooltip: 'QRIS Cloud Live Active',
                onPressed: () {
                  Fluttertoast.showToast(msg: 'Sesi QRIS terhubung ke Cloud Firestore');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // Header Title & Subtitle
                    Text(
                      'Digital Wallet QRIS',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sesi Pembayaran Cloud Firestore Aktif',
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main Content: Responsive 2-column or 1-column layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 650) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    _buildBalanceCard(),
                                    const SizedBox(height: 24),
                                    _buildPaymentMethodsSection(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 5,
                                child: _buildQrCodeCard(),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildQrCodeCard(),
                              const SizedBox(height: 24),
                              _buildBalanceCard(),
                              const SizedBox(height: 24),
                              _buildPaymentMethodsSection(),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 32),

                    // Pay Now Action Button
                    _buildPayNowActionArea(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQrCodeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(68, 42, 34, 0.06),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SCAN QRIS',
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: colorOnSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorSecondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'BEE-COFFEE-01',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // QR Code Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 200,
                  color: colorPrimary,
                ),
                const SizedBox(height: 6),
                Text(
                  'QRIS Standar Nasional Pembayaran Digital',
                  style: GoogleFonts.workSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Total Tagihan:',
            style: GoogleFonts.workSans(
              fontSize: 13,
              color: colorOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rp ${_formatCurrency(widget.totalAmount)}',
            style: GoogleFonts.sourceSerif4(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SALDO MERCHANT (FIREBASE)',
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: colorOnSurfaceVariant,
                ),
              ),
              const Icon(Icons.account_balance_wallet, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${_formatCurrency(_walletBalance)}',
            style: GoogleFonts.sourceSerif4(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _handleTopUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorSecondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Top Up Saldo',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode QRIS Didukung',
          style: GoogleFonts.sourceSerif4(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorSurfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorSecondary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.qr_code_2, color: colorSecondary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QRIS All Payment',
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BCA, Mandiri, BRI, GoPay, OVO, ShopeePay, Dana',
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayNowActionArea() {
    return Column(
      children: [
        Text(
          "Pelanggan dapat melakukan scan QR di atas. Anda juga dapat konfirmasi pembayaran langsung di bawah ini.",
          textAlign: TextAlign.center,
          style: GoogleFonts.workSans(
            fontSize: 12,
            color: colorOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorSecondary,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'KONFIRMASI PEMBAYARAN QRIS',
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
