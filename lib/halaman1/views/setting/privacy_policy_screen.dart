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
                                border: Border.all(
                                  color: theme.dividerColor,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 32.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),

                                  // Section 1: Introduction
                                  Text(
                                    'Introduction',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'At BGA Co., we honor the sanctity of your personal space, both physical and digital. This Privacy Policy details our practices regarding the collection, use, and safeguarding of your personal information when you use our services.',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'We approach data with the same careful consideration and respect as we do our curated collections. By engaging with our platform, you consent to the practices outlined in this document, which is designed to be as transparent and enduring as our ethos.',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Paper Divider
                                  Center(
                                    child: Container(
                                      width: 120,
                                      height: 1,
                                      color: theme.dividerColor,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Section 2: Information We Collect
                                  Text(
                                    'Information We Collect',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'To provide an authentic and tailored experience, we gather certain details when you interact with BGA Co.:',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildBulletItem(
                                    label: 'Identity Data:',
                                    text:
                                        'Includes your name, username, or similar identifiers.',
                                  ),
                                  _buildBulletItem(
                                    label: 'Contact Data:',
                                    text:
                                        'Such as billing address, delivery address, email address, and telephone numbers.',
                                  ),
                                  _buildBulletItem(
                                    label: 'Transaction Data:',
                                    text:
                                        'Details about payments to and from you, and other details of products or services you have purchased from us.',
                                  ),
                                  _buildBulletItem(
                                    label: 'Technical Data:',
                                    text:
                                        'Internet protocol (IP) address, your login data, browser type and version, time zone setting and location.',
                                  ),
                                  const SizedBox(height: 28),

                                  // Section 3: How We Use Your Data (Highlighted Box)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: theme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.dividerColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'How We Use Your Data',
                                          style: GoogleFonts.sourceSerif4(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'We deploy your data judiciously, strictly to enhance our relationship and service delivery. Key uses include:',
                                          style: GoogleFonts.workSans(
                                            fontSize: 15,
                                            height: 1.6,
                                            color: theme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildSimpleBulletItem(
                                          'Processing and fulfilling your orders with precision.',
                                        ),
                                        _buildSimpleBulletItem(
                                          'Managing our relationship with you, including notifying you about changes to our terms or privacy policy.',
                                        ),
                                        _buildSimpleBulletItem(
                                          'Curating recommendations that align with your demonstrated aesthetic preferences.',
                                        ),
                                        _buildSimpleBulletItem(
                                          'Improving our platform layout, ensuring the digital environment remains uncluttered and functional.',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Section 4: Data Security
                                  Text(
                                    'Data Security',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'We have instituted rigorous security measures to prevent your personal data from being accidentally lost, used, or accessed in an unauthorized way, altered, or disclosed.',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Access to your personal data is limited strictly to those employees, agents, contractors, and other third parties who have a defined business need to know. They are subject to a strict duty of confidentiality.',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'While we strive to use commercially acceptable means to protect your personal information, remember that no method of transmission over the Internet is 100% secure.',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: theme.onSurfaceVariant,
                                    ),
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
                                          'Effective Date: October 24, 2023',
                                          style: GoogleFonts.workSans(
                                            fontSize: 13,
                                            color: theme.outlineColor,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _showSnackBar(
                                              context,
                                              'PDF Privacy Policy berhasil diunduh',
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Text(
                                            'Download PDF Version',
                                            style: GoogleFonts.workSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: theme.secondaryColor,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  theme.secondaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Decorative Header Bar Accent Centered at Top of Card
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
