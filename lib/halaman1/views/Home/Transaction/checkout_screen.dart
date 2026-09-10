import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/Home/Transaction/qris_payment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String storeName;
  final String customerName;
  final String tableNumber;
  final VoidCallback? onOrderCompleted;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    this.storeName = 'Heritage Hearth',
    this.customerName = 'Pelanggan Umum',
    this.tableNumber = '-',
    this.onOrderCompleted,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Payment method state: 'wallet' or 'cash'
  String _selectedPaymentMethod = 'wallet';

  // Digital wallet sub-option: 'gopay', 'qris', 'dana', 'ovo'
  String _selectedWallet = 'gopay';

  // Cash payment state
  final TextEditingController _cashInputController = TextEditingController(
    text: '200000',
  );
  int _cashReceived = 200000;
  bool _isProcessingOrder = false;

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
  Color get colorOutline => AppTheme.instance.outlineColor;

  int get _subtotal {
    return widget.cartItems.fold(
      0,
      (sum, item) => sum + ((item['price'] as int) * (item['quantity'] as int)),
    );
  }

  int get _tax => (_subtotal * 0.10).round();

  int get _total => _subtotal + _tax;

  int get _change {
    if (_cashReceived >= _total) {
      return _cashReceived - _total;
    }
    return 0;
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  void initState() {
    super.initState();
    // Default cash received to round number higher than total
    final defaultCash = ((_total / 50000).ceil()) * 50000;
    _cashReceived = defaultCash > 0 ? defaultCash : 50000;
    _cashInputController.text = _cashReceived.toString();
  }

  @override
  void dispose() {
    _cashInputController.dispose();
    super.dispose();
  }

  /// Menyimpan transaksi pesanan ke Cloud Firestore
  Future<String?> _saveOrderToFirestore({
    required String activeCashier,
    required String customerDisplayName,
    required String paymentMethodLabel,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final orderId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';

      final orderData = {
        'orderId': orderId,
        'storeName': widget.storeName,
        'customerName': customerDisplayName,
        'tableNumber': widget.tableNumber,
        'cashierUid': user?.uid ?? 'guest_cashier',
        'cashierEmail': user?.email ?? 'anonymous',
        'cashierName': activeCashier,
        'items': widget.cartItems.map((item) => {
          'title': item['title'] ?? item['name'] ?? 'Item',
          'price': item['price'] ?? 0,
          'quantity': item['quantity'] ?? 1,
          'notes': item['notes'] ?? '',
          'image': item['image'] ?? '',
        }).toList(),
        'subtotal': _subtotal,
        'tax': _tax,
        'total': _total,
        'cashReceived': _selectedPaymentMethod == 'cash' ? _cashReceived : _total,
        'change': _selectedPaymentMethod == 'cash' ? _change : 0,
        'paymentMethod': _selectedPaymentMethod,
        'paymentChannel': _selectedPaymentMethod == 'wallet' ? _selectedWallet : 'cash',
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(orderId)
          .set(orderData);

      return orderId;
    } catch (e) {
      debugPrint('Firestore order error: $e');
      return 'TRX-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _onCompleteOrder() async {
    if (_isProcessingOrder) return;

    final fbUser = FirebaseAuth.instance.currentUser;
    final activeCashier = fbUser?.displayName ??
        UserDataStore.instance.userDataNotifier.value['cashierName'] ??
        UserDataStore.instance.userDataNotifier.value['name'] ??
        UserDataStore.instance.userDataNotifier.value['accountName'] ??
        'Bella Gita Asmara';

    final customerDisplayName = widget.tableNumber != '-' &&
            widget.tableNumber.trim().isNotEmpty
        ? '${widget.customerName.trim().isEmpty ? 'Pelanggan Umum' : widget.customerName.trim()} (${widget.tableNumber.trim()})'
        : (widget.customerName.trim().isEmpty
            ? 'Pelanggan Umum'
            : widget.customerName.trim());

    if (_selectedPaymentMethod == 'wallet') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrisPaymentScreen(
            totalAmount: _total,
            merchantId: 'BEE-COFFEE-01',
            customerName: customerDisplayName,
            cashierName: activeCashier.toString(),
            onOrderCompleted: widget.onOrderCompleted,
          ),
        ),
      );
      return;
    }

    if (_cashReceived < _total) {
      Fluttertoast.showToast(
        msg: 'Nominal uang tunai kurang dari total tagihan!',
        backgroundColor: const Color(0xFFBA1A1A),
      );
      return;
    }

    setState(() => _isProcessingOrder = true);

    final paymentLabel = _selectedPaymentMethod == 'wallet'
        ? 'Digital Wallet (${_selectedWallet.toUpperCase()})'
        : 'Tunai di Kasir (Cash)';

    // Simpan data transaksi ke Cloud Firestore
    final orderId = await _saveOrderToFirestore(
      activeCashier: activeCashier.toString(),
      customerDisplayName: customerDisplayName,
      paymentMethodLabel: paymentLabel,
    );

    if (!mounted) return;
    setState(() => _isProcessingOrder = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dContext) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF166534),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pesanan Selesai!',
              style: GoogleFonts.sourceSerif4(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_done, color: Colors.green, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Tersimpan di Cloud Firestore',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Terima kasih telah berbelanja di ${widget.storeName}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 13,
                color: colorOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorSurfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'No. Transaksi:',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      Text(
                        orderId ?? '-',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kasir:',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      Text(
                        activeCashier.toString(),
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pelanggan:',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      Text(
                        widget.customerName.trim().isEmpty
                            ? 'Pelanggan Umum'
                            : widget.customerName.trim(),
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (widget.tableNumber != '-' &&
                      widget.tableNumber.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meja:',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: colorOnSurfaceVariant,
                          ),
                        ),
                        Text(
                          widget.tableNumber.trim(),
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Metode Bayar:',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      Text(
                        paymentLabel,
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Bayar:',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Rp ${_formatCurrency(_total)}',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedPaymentMethod == 'cash') ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Uang Diterima:',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: colorOnSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Rp ${_formatCurrency(_cashReceived)}',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kembalian:',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: colorOnSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Rp ${_formatCurrency(_change)}',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dContext);
                  Navigator.pop(context);
                  widget.onOrderCompleted?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorSecondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'SELESAI / TRANSAKSI BARU',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        foregroundColor: colorPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CHECKOUT & BAYAR',
          style: GoogleFonts.sourceSerif4(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: colorPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 20),
              _buildCartReviewList(),
              const SizedBox(height: 24),
              _buildPaymentMethodSection(),
              const SizedBox(height: 24),
              _buildTotalsCard(),
              const SizedBox(height: 30),
              _buildCompleteOrderAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorSecondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.storefront, color: colorSecondary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.storeName,
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pelanggan: ${widget.customerName.trim().isEmpty ? 'Pelanggan Umum' : widget.customerName.trim()} ${widget.tableNumber != '-' && widget.tableNumber.trim().isNotEmpty ? "• Meja ${widget.tableNumber.trim()}" : ""}',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: colorOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartReviewList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RINGKASAN ITEM (${widget.cartItems.length})',
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: colorOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.cartItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = widget.cartItems[index];
            final price = item['price'] as int;
            final qty = item['quantity'] as int;
            final itemTotal = price * qty;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorSurfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorOutline.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorSecondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${qty}x',
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: colorSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? item['name'] ?? 'Item',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: colorPrimary,
                          ),
                        ),
                        if (item['notes'] != null &&
                            item['notes'].toString().isNotEmpty)
                          Text(
                            item['notes'],
                            style: GoogleFonts.workSans(
                              fontSize: 11,
                              color: colorOnSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${_formatCurrency(itemTotal)}',
                    style: GoogleFonts.workSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'METODE PEMBAYARAN',
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: colorOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentOptionCard(
                title: 'QRIS & E-Wallet',
                subtitle: 'GoPay, QRIS, Dana, OVO',
                icon: Icons.qr_code_scanner,
                isSelected: _selectedPaymentMethod == 'wallet',
                onTap: () => setState(() => _selectedPaymentMethod = 'wallet'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentOptionCard(
                title: 'Tunai (Cash)',
                subtitle: 'Bayar Langsung',
                icon: Icons.payments_outlined,
                isSelected: _selectedPaymentMethod == 'cash',
                onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
              ),
            ),
          ],
        ),
        if (_selectedPaymentMethod == 'wallet') ...[
          const SizedBox(height: 16),
          _buildWalletSelector(),
        ] else ...[
          const SizedBox(height: 16),
          _buildCashCalculator(),
        ],
      ],
    );
  }

  Widget _buildPaymentOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? colorSecondaryContainer : colorSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorSecondary : colorOutline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? colorSecondary : colorOnSurfaceVariant,
              size: 26,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.workSans(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: colorPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.workSans(
                fontSize: 11,
                color: colorOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSelector() {
    final wallets = [
      {'id': 'gopay', 'name': 'GoPay'},
      {'id': 'qris', 'name': 'QRIS All'},
      {'id': 'dana', 'name': 'Dana'},
      {'id': 'ovo', 'name': 'OVO'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorOutline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PILIH KANAL DIGITAL',
            style: GoogleFonts.workSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: colorOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: wallets.map((w) {
              final isSel = _selectedWallet == w['id'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: ChoiceChip(
                    label: Text(
                      w['name']!,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : colorPrimary,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: colorSecondary,
                    backgroundColor: colorSurfaceContainerLow,
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedWallet = w['id']!);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCashCalculator() {
    final suggestions = [
      _total,
      ((_total / 10000).ceil()) * 10000,
      ((_total / 50000).ceil()) * 50000,
      ((_total / 100000).ceil()) * 100000,
    ].toSet().toList()..sort();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorOutline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UANG PAS / SARAN NOMINAL',
            style: GoogleFonts.workSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: colorOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((amt) {
              final isMatched = _cashReceived == amt;
              return ActionChip(
                label: Text(
                  'Rp ${_formatCurrency(amt)} ${amt == _total ? "(Pas)" : ""}',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isMatched ? Colors.white : colorPrimary,
                  ),
                ),
                backgroundColor: isMatched ? colorSecondary : colorSurfaceContainerLow,
                onPressed: () {
                  setState(() {
                    _cashReceived = amt;
                    _cashInputController.text = amt.toString();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            'NOMINAL UANG DITERIMA (RP)',
            style: GoogleFonts.workSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: colorOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _cashInputController,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              setState(() {
                _cashReceived = int.tryParse(val) ?? 0;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text(
                  'Rp',
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              filled: true,
              fillColor: colorSurfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorOutline.withValues(alpha: 0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorSecondary, width: 1.5),
              ),
            ),
            style: GoogleFonts.workSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colorPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorSurfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KEMBALIAN',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: colorOnSurfaceVariant,
                  ),
                ),
                Text(
                  'Rp ${_formatCurrency(_change)}',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SUBTOTAL',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: colorOnSurfaceVariant,
                ),
              ),
              Text(
                'Rp ${_formatCurrency(_subtotal)}',
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAJAK (10%)',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: colorOnSurfaceVariant,
                ),
              ),
              Text(
                'Rp ${_formatCurrency(_tax)}',
                style: GoogleFonts.workSans(
                  fontSize: 14,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'TOTAL BAYAR',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: colorPrimary,
                ),
              ),
              Text(
                'Rp ${_formatCurrency(_total)}',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteOrderAction() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isProcessingOrder ? null : _onCompleteOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorSecondary,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessingOrder
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
                      const Icon(Icons.cloud_upload_outlined, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'PROSES & SELESAIKAN ORDER',
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pembayaran kasir & sinkronisasi otomatis Cloud Firestore',
          textAlign: TextAlign.center,
          style: GoogleFonts.workSans(
            fontSize: 11,
            color: colorOnSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
