import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    final theme = AppTheme.instance;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.workSans(color: Colors.white),
        ),
        backgroundColor: theme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBulletItem({required String label, required String text}) {
    final theme = AppTheme.instance;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 8.0),
            child: Text(
              '•',
              style: TextStyle(
                color: theme.secondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.workSans(
                  fontSize: 15,
                  height: 1.6,
                  color: theme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBulletItem(String text) {
    final theme = AppTheme.instance;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 8.0),
            child: Text(
              '•',
              style: TextStyle(
                color: theme.secondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.workSans(
                fontSize: 15,
                height: 1.6,
                color: theme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.instance;
    final theme = AppTheme.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: loc.currentLanguageNotifier,
          builder: (context, langCode, child) {
            return SelectionArea(
              child: Scaffold(
                backgroundColor: theme.backgroundColor,

                // Top AppBar
                appBar: AppBar(
                  backgroundColor: theme.backgroundColor,
                  elevation: 0,
                  scrolledUnderElevation: 0.5,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    loc.getText('privacy_policy'),
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1.0),
                    child: Container(color: theme.dividerColor, height: 1.0),
                  ),
                ),

                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Main Soft Shadow Paper Container
                            Container(
                              decoration: BoxDecoration(
                                color: theme.surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.dividerColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Firebase Cloud Privacy Compliance Card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.secondaryColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.secondaryColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.verified_user_rounded,
                                          color: theme.secondaryColor,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Keamanan Cloud Firebase Terverifikasi',
                                                style: GoogleFonts.sourceSerif4(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.primaryColor,
                                                ),
                                              ),
                                              Text(
                                                'Data kasir, transaksi, dan autentikasi dilindungi dengan enkripsi standar Google Cloud (TLS & AES-256).',
                                                style: GoogleFonts.workSans(
                                                  fontSize: 12,
                                                  color: theme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Section 1: Introduction
                                  Text(
                                    '1. Pengantar & Komitmen Privasi',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Selamat datang di aplikasi Cashier BGA Co. Kami menghargai privasi dan kepercayaan Anda. Kebijakan Privasi ini menjelaskan bagaimana informasi operasional kasir, data staf, dan data transaksi dikumpulkan, dilindungi, dan dikelola secara aman melalui layanan cloud Firebase.',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Section 2: Data We Collect
                                  Text(
                                    '2. Data yang Dikumpulkan & Disimpan',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _buildBulletItem(
                                    label: 'Data Akun & Autentikasi:',
                                    text:
                                        'Alamat email terdaftar, ID Kasir, nama lengkap, dan kredensial terenkripsi yang dikelola oleh Firebase Authentication.',
                                  ),
                                  _buildBulletItem(
                                    label: 'Data Operasional Toko:',
                                    text:
                                        'Jadwal shift, nama outlet, riwayat pesanan, dan laporan transaksi yang disimpan secara realtime di Cloud Firestore.',
                                  ),
                                  _buildBulletItem(
                                    label: 'Preferensi Aplikasi:',
                                    text:
                                        'Pilihan tema, bahasa, dan pengaturan notifikasi yang disinkronkan ke akun cloud kasir.',
                                  ),
                                  const SizedBox(height: 28),

                                  // Section 3: How We Use Your Data
                                  Text(
                                    '3. Penggunaan & Keamanan Data Cloud',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _buildSimpleBulletItem(
                                    'Memproses transaksi kasir dan sinkronisasi stok secara realtime.',
                                  ),
                                  _buildSimpleBulletItem(
                                    'Memastikan akses hanya diberikan kepada staf dan kasir terverifikasi.',
                                  ),
                                  _buildSimpleBulletItem(
                                    'Menyediakan cadangan data cloud yang aman sehingga data tidak hilang saat pergantian perangkat.',
                                  ),
                                  _buildSimpleBulletItem(
                                    'Data Anda tidak akan pernah dijual atau dibagikan kepada pihak ketiga di luar ekosistem BGA Co.',
                                  ),
                                  const SizedBox(height: 32),

                                  // Footer Metadata & Action
                                  Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: theme.dividerColor,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: [
                                        Text(
                                          'Terakhir Diperbarui: 2026 • BGA Co. Cloud',
                                          style: GoogleFonts.workSans(
                                            fontSize: 13,
                                            color: theme.outlineColor,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _showSnackBar(
                                              context,
                                              'Dokumen Kebijakan Privasi Firebase aktif',
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(4),
                                          child: Text(
                                            'Status Keamanan Cloud: Aktif',
                                            style: GoogleFonts.workSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: theme.secondaryColor,
                                              decoration: TextDecoration.underline,
                                              decorationColor: theme.secondaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Decorative Header Bar Accent
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: theme.secondaryColor,
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
