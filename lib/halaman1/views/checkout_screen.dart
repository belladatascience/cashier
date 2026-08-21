import 'dart:typed_data';

import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/views/qris_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String storeName;
  final VoidCallback? onOrderCompleted;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    this.storeName = 'Heritage Hearth',
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

  // Dynamic Color Tokens
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorSecondary => AppTheme.instance.secondaryColor;
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

  void _onCompleteOrder() {
    if (_selectedPaymentMethod == 'wallet' && _selectedWallet == 'qris') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrisPaymentScreen(
            totalAmount: _total,
            merchantId: 'BEE-COFFEE-01',
            onOrderCompleted: widget.onOrderCompleted,
          ),
        ),
      );
      return;
    }

    final paymentLabel = _selectedPaymentMethod == 'wallet'
        ? 'Digital Wallet (${_selectedWallet.toUpperCase()})'
        : 'Cash in Store';

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
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
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
              'Order Placed!',
              style: GoogleFonts.sourceSerif4(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you for your order at ${widget.storeName}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 13,
                color: colorOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
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
                        'Payment Method:',
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
                        'Total Paid:',
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
                          'Change (Kembalian):',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: colorOnSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Rp ${_formatCurrency(_change)}',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dContext);
                  if (widget.onOrderCompleted != null) {
                    widget.onOrderCompleted!();
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'RETURN TO SHOP',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
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
              'Checkout',
              style: GoogleFonts.sourceSerif4(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Your Order Summary
                    _buildSectionTitle('Your Order'),
                    _buildOrderItemsList(),
                    const SizedBox(height: 28),

                    // Section 2: Payment Method Selection
                    _buildSectionTitle('Payment Method'),
                    _buildPaymentMethods(),
                    const SizedBox(height: 28),

                    // Section 3: Totals Summary Card
                    _buildTotalsCard(),
                    const SizedBox(height: 32),

                    // Section 4: Action Complete Order
                    _buildCompleteOrderAction(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorPrimary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.sourceSerif4(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorPrimary,
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    if (widget.cartItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Tidak ada pesanan.',
          style: GoogleFonts.workSans(color: colorOnSurfaceVariant),
        ),
      );
    }

    return Column(
      children: widget.cartItems.map((item) {
        final itemTotal = (item['price'] as int) * (item['quantity'] as int);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorPrimary.withValues(alpha: 0.05)),
            ),
          ),
          child: Row(
            children: [
              // Image Thumbnail Box
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProductThumbnail(
                    item['image'],
                    width: 56,
                    height: 56,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Item',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'QTY: ${item['quantity']}',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              Text(
                'Rp ${_formatCurrency(itemTotal)}',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductThumbnail(
    dynamic imageSource, {
    double width = 56,
    double height = 56,
  }) {
    if (imageSource is Uint8List) {
      return Image.memory(
        imageSource,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else if (imageSource is String && imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildAssetWithFallback(imageSource, width: width, height: height),
      );
    } else if (imageSource is String && imageSource.isNotEmpty) {
      return Image.asset(
        imageSource,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildAssetWithFallback(imageSource, width: width, height: height),
      );
    }
    return _buildProductFallback(width: width, height: height);
  }

  Widget _buildAssetWithFallback(
    String path, {
    double width = 56,
    double height = 56,
  }) {
    String fallbackAsset = 'assets/images/sandwich.jpg';
    if (path.contains('drink') ||
        path.contains('latte') ||
        path.contains('tea') ||
        path.contains('citrus') ||
        path.contains('chocolate')) {
      fallbackAsset = 'assets/images/ice latte.jpg';
    } else if (path.contains('dessert') ||
        path.contains('cheesecake') ||
        path.contains('tiramisu')) {
      fallbackAsset = 'assets/images/caffee1.webp';
    }
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _buildProductFallback(width: width, height: height),
    );
  }

  Widget _buildProductFallback({double width = 56, double height = 56}) {
    return Container(
      width: width,
      height: height,
      color: colorSurfaceContainerHigh,
      child: Icon(
        Icons.restaurant_menu,
        size: width * 0.5,
        color: colorPrimary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 550;
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildWalletCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCashCard()),
                ],
              )
            : Column(
                children: [
                  _buildWalletCard(),
                  const SizedBox(height: 16),
                  _buildCashCard(),
                ],
              );
      },
    );
  }

  Widget _buildWalletCard() {
    final isSelected = _selectedPaymentMethod == 'wallet';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = 'wallet';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? colorSurfaceContainerLowest : colorSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorSecondary
                : colorPrimary.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorSecondary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: isSelected
                      ? colorSecondary
                      : colorPrimary.withValues(alpha: 0.6),
                  size: 24,
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? colorSecondary
                      : colorPrimary.withValues(alpha: 0.3),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'DIGITAL WALLET',
              style: GoogleFonts.workSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isSelected ? colorPrimary : colorOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Divider(color: colorPrimary.withValues(alpha: 0.08)),
            const SizedBox(height: 8),

            // Wallet Options Sublist
            _buildWalletOptionRow(
              'GoPay',
              Icons.account_balance_wallet,
              'gopay',
            ),
            _buildWalletOptionRow('QRIS', Icons.qr_code_2, 'qris'),
            _buildWalletOptionRow('DANA', Icons.wallet, 'dana'),
            _buildWalletOptionRow('OVO', Icons.payments, 'ovo'),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletOptionRow(String label, IconData icon, String value) {
    final isOptionSelected =
        _selectedWallet == value && _selectedPaymentMethod == 'wallet';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = 'wallet';
          _selectedWallet = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isOptionSelected
                      ? colorPrimary
                      : colorPrimary.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: isOptionSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isOptionSelected
                        ? colorPrimary
                        : colorOnSurfaceVariant,
                  ),
                ),
              ],
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOptionSelected
                      ? colorSecondary
                      : colorPrimary.withValues(alpha: 0.2),
                ),
              ),
              child: isOptionSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorSecondary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashCard() {
    final isSelected = _selectedPaymentMethod == 'cash';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = 'cash';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? colorSurfaceContainerLowest : colorSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorSecondary
                : colorPrimary.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorSecondary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.payments,
                  color: isSelected
                      ? colorSecondary
                      : colorPrimary.withValues(alpha: 0.6),
                  size: 24,
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? colorSecondary
                      : colorPrimary.withValues(alpha: 0.3),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'CASH IN STORE',
              style: GoogleFonts.workSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isSelected ? colorPrimary : colorOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Divider(color: colorPrimary.withValues(alpha: 0.08)),
            const SizedBox(height: 12),

            // Cash Input Field
            Text(
              'UANG MASUK',
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
              onTap: () {
                if (!isSelected) {
                  setState(() => _selectedPaymentMethod = 'cash');
                }
              },
              onChanged: (val) {
                setState(() {
                  _cashReceived = int.tryParse(val) ?? 0;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 8,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Text(
                    'Rp',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                filled: true,
                fillColor: colorSurfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorPrimary.withValues(alpha: 0.15),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: colorPrimary.withValues(alpha: 0.15),
                  ),
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

            // Kembalian Output Row
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
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(93, 64, 55, 0.05),
            blurRadius: 12,
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
                'TAX (10%)',
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
                'TOTAL',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: colorPrimary,
                ),
              ),
              Text(
                'Rp ${_formatCurrency(_total)}',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 28,
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
            onPressed: _onCompleteOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 20),
                const SizedBox(width: 10),
                Text(
                  'COMPLETE ORDER',
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Secure payment processed by ${widget.storeName}',
          textAlign: TextAlign.center,
          style: GoogleFonts.workSans(
            fontSize: 12,
            color: colorOnSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
