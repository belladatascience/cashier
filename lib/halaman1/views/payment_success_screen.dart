import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
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

  String get _activeCashierName {
    if (widget.cashierName != null && widget.cashierName!.trim().isNotEmpty) {
      return widget.cashierName!.trim();
    }
    final stored =
        UserDataStore.instance.userDataNotifier.value['cashierName'] ??
        UserDataStore.instance.userDataNotifier.value['name'] ??
        UserDataStore.instance.userDataNotifier.value['accountName'];
    return stored != null && stored.toString().trim().isNotEmpty
        ? stored.toString().trim()
        : 'Bella Saputra';
  }

  @override
  void initState() {
    super.initState();
    _formattedTime = _getFormattedCurrentTime();
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
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $hour:$minute $period';
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _handleReturnHome() {
    if (widget.onOrderCompleted != null) {
      widget.onOrderCompleted!();
    }
    // Return to main app screen (HomeScreen)
    Navigator.popUntil(
      context,
      (route) =>
          route.settings.name == 'HomeScreen' ||
          route.settings.name == '/HomeScreen' ||
          route.isFirst,
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
              icon: Icon(Icons.menu, color: colorPrimary),
              onPressed: () {},
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
                icon: Icon(Icons.account_circle, color: colorOnSurfaceVariant),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: colorSurfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorSurfaceContainerHigh),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(68, 42, 34, 0.08),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Success Icon Circle
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3E9C2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(69, 73, 45, 0.15),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Color(0xFF45492D),
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header Text
                      Text(
                        'Payment Received!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The funds have been successfully credited to your shop account.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
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
                                  'Amount Paid',
                                  style: GoogleFonts.workSans(
                                    fontSize: 14,
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
                            _buildDetailRow('Cashier', _activeCashierName),
                            const SizedBox(height: 12),

                            // Customer
                            _buildDetailRow('Customer', widget.customerName),
                            const SizedBox(height: 12),

                            // Method
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Method',
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: colorOnSurfaceVariant,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner,
                                      size: 18,
                                      color: colorSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.paymentMethod,
                                      style: GoogleFonts.workSans(
                                        fontSize: 14,
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
                                  'Transaction ID',
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: colorOnSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  widget.transactionId,
                                  style: GoogleFonts.workSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Time
                            _buildDetailRow('Time', _formattedTime),
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
                              const Icon(Icons.receipt_long, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'LIHAT TRANSAKSI',
                                style: GoogleFonts.workSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
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
      },
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorPrimary,
          ),
        ),
      ],
    );
  }
}
