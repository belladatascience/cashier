import 'package:cashier/extension/navigator.dart';
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cashier/CASHIER/widgets/animated_cartoon_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

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
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;
    final fbUser = FirebaseAuth.instance.currentUser;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return SelectionArea(
          child: Scaffold(
            backgroundColor: theme.backgroundColor,

            // Top App Bar
            appBar: AppBar(
              backgroundColor: theme.backgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Tentang Aplikasi',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
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
                  vertical: 36.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App Logo & Branding (Coffeedata Lottie Animation)
                        const AnimatedCartoonLogo(
                          height: 140,
                          borderRadius: 20,
                          defaultAssetPath:
                              'assets/animation/cashier_header.json',
                          showEditButton: false,
                        ),
                        const SizedBox(height: 20),

                        // Title: CASHIER
                        Text(
                          'CASHIER BGA CO.',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle: Cashier System v1.2.4
                        Text(
                          'FIREBASE CLOUD POWERED • V1.2.4',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: theme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Designed for Bella Gita Asmara, S.E., M.M.',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Section: Firebase Cloud Status Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.secondaryColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.secondaryColor.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.secondaryColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.cloud_done_rounded,
                                      color: theme.secondaryColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Status Firebase Cloud',
                                          style: GoogleFonts.sourceSerif4(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        Text(
                                          'Sistem Terhubung ke Google Cloud Firebase',
                                          style: GoogleFonts.workSans(
                                            fontSize: 12,
                                            color: theme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2E7D32),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Online',
                                          style: GoogleFonts.workSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 12),

                              _buildCloudServiceRow(
                                theme: theme,
                                icon: Icons.security_rounded,
                                title: 'Firebase Authentication',
                                subtitle: fbUser != null
                                    ? 'Login: ${fbUser.email ?? "Kasir"}'
                                    : 'Sesi Kasir Aktif',
                              ),
                              const SizedBox(height: 10),
                              _buildCloudServiceRow(
                                theme: theme,
                                icon: Icons.storage_rounded,
                                title: 'Cloud Firestore Database',
                                subtitle: 'Sinkronisasi Realtime Staff, Shift & Transaksi',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 1: Our Story Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: theme.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with Fire Icon
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department_rounded,
                                    color: theme.secondaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Our Story',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Paragraph 1
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.workSans(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: theme.onSurfaceVariant,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'BGA Co. was created with a simple purpose: ',
                                    ),
                                    TextSpan(
                                      text:
                                          'to make small business management easier and more efficient.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Paragraph 2
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.workSans(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: theme.onSurfaceVariant,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Through years of experience helping entrepreneurs manage their daily operations, I realized that ',
                                    ),
                                    TextSpan(
                                      text:
                                          'many small businesses still struggle with manual recording, complex inventory tracking, and time-consuming cashier processes.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Paragraph 3
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.workSans(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: theme.onSurfaceVariant,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'This app was designed from the ground up to be ',
                                    ),
                                    TextSpan(
                                      text:
                                          'fast, intuitive, and practical for daily business activities.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Paragraph 4
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.workSans(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: theme.onSurfaceVariant,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'I believe technology should not only be accessible to large companies. ',
                                    ),
                                    TextSpan(
                                      text:
                                          'Technology should also empower small businesses to grow and succeed.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Paragraph 5
                              Text(
                                'I hope this app can become a small part of every entrepreneur’s journey toward building a more organized, efficient, and successful business.',
                                style: GoogleFonts.workSans(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: theme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Paragraph 6 (Purpose)
                              Text(
                                'Created with a simple purpose: making small businesses easier to manage.',
                                style: GoogleFonts.workSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  height: 1.6,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Founder Signature Line
                              Text(
                                '— Bella Gita Asmara, S.E., M.M.',
                                style: GoogleFonts.workSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: theme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Bottom Footer Area
                        Container(
                          padding: const EdgeInsets.only(top: 24),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: theme.dividerColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Social Buttons Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton.filledTonal(
                                    icon: const Icon(Icons.camera_alt_outlined),
                                    onPressed: () => _showSnackBar(
                                      context,
                                      'Instagram BGA Co.',
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          theme.surfaceContainerLow,
                                      foregroundColor: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton.filledTonal(
                                    icon: const Icon(Icons.thumb_up_outlined),
                                    onPressed: () => _showSnackBar(
                                      context,
                                      'Facebook BGA Co.',
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          theme.surfaceContainerLow,
                                      foregroundColor: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton.filledTonal(
                                    icon: const Icon(
                                      Icons.alternate_email_outlined,
                                    ),
                                    onPressed: () => _showSnackBar(
                                      context,
                                      'Twitter / X BGA Co.',
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          theme.surfaceContainerLow,
                                      foregroundColor: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Footer Credit Text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'MADE WITH BELLA GITA ASMARA IN INDONESIA',
                                    style: GoogleFonts.workSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                      color: theme.outlineColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: theme.secondaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
  }

  Widget _buildCloudServiceRow({
    required AppTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.secondaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.workSans(
                  fontSize: 11.5,
                  color: theme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
