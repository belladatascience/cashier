import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/views/about_app_screen.dart';
import 'package:cashier/halaman1/views/appearance_settings_screen.dart';
import 'package:cashier/halaman1/views/change_password_screen.dart';
import 'package:cashier/halaman1/views/edit_personal_info_screen.dart';
import 'package:cashier/halaman1/views/help_center_screen.dart';
import 'package:cashier/halaman1/views/language_screen.dart';
import 'package:cashier/halaman1/views/notification_settings_screen.dart';
import 'package:cashier/halaman1/views/privacy_policy_screen.dart';
import 'package:cashier/halaman1/views/security_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _getAppearanceLabel(String themeMode) {
    final loc = AppLocalization.instance;
    if (themeMode == 'dark') return loc.getText('theme_dark');
    if (themeMode == 'system') return loc.getText('theme_system');
    return loc.getText('theme_light');
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;
    final loc = AppLocalization.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, currentThemeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: loc.currentLanguageNotifier,
          builder: (context, currentLangCode, child) {
            return Scaffold(
              backgroundColor: theme.backgroundColor,

              // Top App Bar
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  loc.getText('settings_title'),
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                centerTitle: true,
              ),

              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        children: [
                          // Account Section
                          _buildSectionCard(
                            title: loc.getText('account_section'),
                            items: [
                              _buildSettingItem(
                                title: loc.getText('edit_personal_info'),
                                onTap: () => context.push(
                                  const EditPersonalInfoScreen(),
                                ),
                              ),
                              _buildSettingItem(
                                title: loc.getText('change_password'),
                                onTap: () =>
                                    context.push(const ChangePasswordScreen()),
                              ),
                              _buildSettingItem(
                                title: loc.getText('security'),
                                onTap: () => context.push(
                                  const SecuritySettingsScreen(),
                                ),
                                showDivider: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Preferences Section
                          _buildSectionCard(
                            title: loc.getText('preferences_section'),
                            items: [
                              _buildSettingItem(
                                title: loc.getText('language'),
                                trailingValue: loc.currentLanguageName,
                                onTap: () async {
                                  await context.push(
                                    LanguageScreen(
                                      currentLanguage: loc.currentLanguageName,
                                    ),
                                  );
                                },
                              ),
                              _buildSettingItem(
                                title: loc.getText('notifications'),
                                onTap: () => context.push(
                                  const NotificationSettingsScreen(),
                                ),
                              ),
                              _buildSettingItem(
                                title: loc.getText('appearance'),
                                trailingValue: _getAppearanceLabel(
                                  currentThemeMode,
                                ),
                                onTap: () async {
                                  await context.push(
                                    const AppearanceSettingsScreen(),
                                  );
                                },
                                showDivider: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Support Section
                          _buildSectionCard(
                            title: loc.getText('support_section'),
                            items: [
                              _buildSettingItem(
                                title: loc.getText('help_center'),
                                onTap: () =>
                                    context.push(const HelpCenterScreen()),
                              ),
                              _buildSettingItem(
                                title: loc.getText('privacy_policy'),
                                onTap: () =>
                                    context.push(const PrivacyPolicyScreen()),
                              ),
                              _buildSettingItem(
                                title: loc.getText('about_app'),
                                onTap: () =>
                                    context.push(const AboutAppScreen()),
                                showDivider: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 36),

                          // Version Footer
                          Text(
                            'VERSION 1.2.4',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: theme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
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

  Widget _buildSectionCard({
    required String title,
    required List<Widget> items,
  }) {
    final theme = AppTheme.instance;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 12,
            ),
            child: Text(
              title,
              style: GoogleFonts.workSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: theme.secondaryColor,
              ),
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),

          // Items List
          Column(children: items),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? trailingValue,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final theme = AppTheme.instance;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.workSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.onSurfaceColor,
                    letterSpacing: -0.2,
                  ),
                ),
                Row(
                  children: [
                    if (trailingValue != null) ...[
                      Text(
                        trailingValue,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.outlineColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: theme.dividerColor, height: 1),
          ),
      ],
    );
  }
}
