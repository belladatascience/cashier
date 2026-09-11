import 'package:cashier/halaman1/database/database_helper.dart';
import 'package:cashier/halaman1/models/transaction_model.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/transaction_data_store.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/Home/Shop/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final int totalAmount;
  final String customerName;
  final String transactionId;
  final String paymentMethod;
  final String? cashierName;
  final VoidCallback? onOrderCompleted;

  const PaymentSuccessScreen({
    super.key,
    this.totalAmount = 18500,
    this.customerName = 'Handky Chang',
    this.transactionId = '#HH-99420',
    this.paymentMethod = 'Digital Wallet',
    this.cashierName,
    this.onOrderCompleted,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  late final String _formattedTime;
  bool _isCloudSynced = false;

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

  String get _activeCashierName {
    if (widget.cashierName != null && widget.cashierName!.trim().isNotEmpty) {
      return widget.cashierName!.trim();
    }
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser?.displayName != null && fbUser!.displayName!.trim().isNotEmpty) {
      return fbUser.displayName!.trim();
    }
    final stored =
        UserDataStore.instance.userDataNotifier.value['cashierName'] ??
        UserDataStore.instance.userDataNotifier.value['name'] ??
        UserDataStore.instance.userDataNotifier.value['accountName'];
    return stored != null && stored.toString().trim().isNotEmpty
        ? stored.toString().trim()
        : 'Bella Gita Asmara';
  }

  @override
  void initState() {
    super.initState();
    _formattedTime = _getFormattedCurrentTime();
    _saveTransactionToDatabaseAndCloud();
  }

  Future<void> _saveTransactionToDatabaseAndCloud() async {
    final activeStore =
        UserDataStore.instance.userDataNotifier.value['storeName'] ??
        'Bella Cafe';
    final subtotal = (widget.totalAmount / 1.1).round();
    final tax = widget.totalAmount - subtotal;
    final fbUser = FirebaseAuth.instance.currentUser;

    // 1. Simpan ke Cloud Firestore
    try {
      final docId = widget.transactionId.replaceAll('#', '').trim();
      await FirebaseFirestore.instance.collection('transactions').doc(docId).set({
        'invoiceNumber': widget.transactionId,
        'orderId': docId,
        'totalAmount': widget.totalAmount,
        'subtotal': subtotal,
        'tax': tax,
        'paymentMethod': widget.paymentMethod,
        'customerName': widget.customerName,
        'cashierName': _activeCashierName,
        'cashierUid': fbUser?.uid ?? 'guest',
        'cashierEmail': fbUser?.email ?? 'anonymous',
        'storeName': activeStore.toString(),
        'status': 'LUNAS',
        'dateTime': _formattedTime,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() => _isCloudSynced = true);
      }
    } catch (e) {
      debugPrint('Firestore write error in PaymentSuccessScreen: $e');
    }

    // 2. Simpan ke SQLite Database Lokal sebagai cadangan
    try {
      final txModel = TransactionModel(
        invoiceNumber: widget.transactionId,
        dateTime: _formattedTime,
        cashierName: _activeCashierName,
        paymentMethod: widget.paymentMethod,
        customerName: widget.customerName,
        subtotal: subtotal,
        tax: tax,
        total: widget.totalAmount,
        status: 'LUNAS',
        storeName: activeStore.toString(),
        items: [
          TransactionItemModel(
            invoiceNumber: widget.transactionId,
            menuName: 'Pesanan Kasir',
            qty: 1,
            price: subtotal,
            subtotal: subtotal,
          ),
        ],
      );

      await TransactionDataStore.instance.addTransaction(txModel);
      await DataBaseHelper().insertTransaction(txModel);
    } catch (e) {
      debugPrint('SQLite write error in PaymentSuccessScreen: $e');
    }
  }

  String _getFormattedCurrentTime() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[now.month - 1];
    final day = now.day;
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$month $day, ${now.year} • $hour:$minute $period';
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _handleReturnHome() {
    HomeScreen.switchToTab(3);
    widget.onOrderCompleted?.call();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Success Icon with Cloud Badge
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF166534),
                        size: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cloud Firestore Sync Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isCloudSynced
                          ? Colors.green.withValues(alpha: 0.12)
                          : colorSecondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isCloudSynced
                            ? Colors.green.shade600
                            : colorSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCloudSynced ? Icons.cloud_done : Icons.cloud_upload_outlined,
                          size: 14,
                          color: _isCloudSynced ? Colors.green.shade800 : colorSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isCloudSynced
                              ? 'Tersinkronisasi ke Cloud Firestore'
                              : 'Menyinkronkan ke Firebase...',
                          style: GoogleFonts.workSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isCloudSynced ? Colors.green.shade800 : colorSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Pembayaran Diterima!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dana pembayaran telah berhasil dicatat dan masuk ke sistem toko.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transaction Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorOutlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Amount Paid Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Dibayar',
                              style: GoogleFonts.workSans(
                                fontSize: 13,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(widget.totalAmount)}',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(),
                        ),

                        // Cashier
                        _buildDetailRow('Kasir', _activeCashierName),
                        const SizedBox(height: 12),

                        // Customer
                        _buildDetailRow('Pelanggan', widget.customerName),
                        const SizedBox(height: 12),

                        // Method
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Metode',
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.payment,
                                  size: 16,
                                  color: colorSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.paymentMethod,
                                  style: GoogleFonts.workSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Transaction ID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'No. Transaksi',
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                            Text(
                              widget.transactionId,
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Time
                        _buildDetailRow('Waktu', _formattedTime),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Return Home Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleReturnHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorSecondary,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'KEMBALI KE RIWAYAT TRANSAKSI',
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 12,
            color: colorOnSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.workSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorPrimary,
          ),
        ),
      ],
    );
  }
}
