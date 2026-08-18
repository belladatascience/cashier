import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
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
                'BGA Co.',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 24,
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
                        // App Logo & Branding
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: theme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.secondaryColor,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 48,
                              color: theme.secondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title: CASHIER
                        Text(
                          'CASHIER',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle: Cashier System v1.2.4
                        Text(
                          'CASHIER SYSTEM V1.2.4',
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Designed for Bella Gita Asmara',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: theme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),

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
                                          'This app was created from a simple belief: ',
                                    ),
                                    TextSpan(
                                      text:
                                          'every business, no matter how small, deserves an easy way to manage its daily operations.',
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
                              Text(
                                'I saw many small business owners working hard to grow their businesses while still recording transactions manually, calculating sales by hand, and sometimes struggling to understand their business performance.',
                                style: GoogleFonts.workSans(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: theme.onSurfaceVariant,
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
                                          'That inspired me to create this cashier app as a simple digital companion for small business owners—helping them ',
                                    ),
                                    TextSpan(
                                      text:
                                          'record transactions, calculate sales, and manage their businesses more easily, quickly, and efficiently.',
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
}
