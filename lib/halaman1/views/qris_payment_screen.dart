import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/views/payment_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QrisPaymentScreen extends StatefulWidget {
  final int totalAmount;
  final String merchantId;
  final VoidCallback? onOrderCompleted;

  const QrisPaymentScreen({
    super.key,
    this.totalAmount = 44000,
    this.merchantId = 'BEE-COFFEE-01',
    this.onOrderCompleted,
  });

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
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
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _handlePayNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          totalAmount: widget.totalAmount,
          customerName: 'Handky Chang',
          transactionId: '#HH-99420',
          paymentMethod: 'Digital Wallet',
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
              'BGA Co.',
              style: GoogleFonts.sourceSerif4(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.account_circle, color: colorPrimary),
                onPressed: () {},
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
                      'Digital Wallet',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your balance and payment methods',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Balance / QRIS Card
                    _buildQrisCard(),
                    const SizedBox(height: 28),

                    // Payment Methods Section
                    _buildPaymentMethodsSection(),
                    const SizedBox(height: 32),

                    // Pay Now Action Area
                    _buildPayNowActionArea(),
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

  Widget _buildQrisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E6BF).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorSecondary.withValues(alpha: 0.4),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(68, 42, 34, 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'SCAN QRIS TO PAY',
            style: GoogleFonts.workSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: colorPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // QR Code Card Container
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorSurfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorOutlineVariant.withValues(alpha: 0.3),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.qr_code_2, size: 160, color: colorPrimary),
                const SizedBox(height: 12),
                Text(
                  'MERCHANT ID: ${widget.merchantId}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: colorPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Total Amount Display
          Text(
            'Rp ${_formatCurrency(widget.totalAmount)}',
            style: GoogleFonts.sourceSerif4(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Subtext Verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, size: 16, color: colorSecondary),
              const SizedBox(width: 6),
              Text(
                'Scan at register to pay instantly',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  color: colorOnSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Buttons: Add Funds & History
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Top up saldo QRIS berhasil!'),
                          backgroundColor: colorSecondary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Add Funds',
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorPrimary,
                    side: BorderSide(
                      color: colorOutlineVariant.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.history, size: 20),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorOutlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Text(
            'Payment Methods',
            style: GoogleFonts.sourceSerif4(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // QRIS Selected Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorSurfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorOutlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(68, 42, 34, 0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorSecondary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.qr_code_2, color: colorSecondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QRIS',
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scan to pay with any supported app',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle, color: colorSecondary, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Link New Payment Method Button
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorOutlineVariant.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: colorPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Link New Payment Method',
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayNowActionArea() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colorOutlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Text(
            "Menunggu pelanggan melakukan scan dan menyelesaikan pembayaran QRIS...",
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 13,
              color: colorOnSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 16),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _handlePayNow,
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
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Waiting...',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
