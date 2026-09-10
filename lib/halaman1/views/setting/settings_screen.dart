import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/services/firebase_auth_service.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/Home/login.dart';
import 'package:cashier/halaman1/views/setting/about_app_screen.dart';
import 'package:cashier/halaman1/views/setting/appearance_settings_screen.dart';
import 'package:cashier/halaman1/views/setting/change_password_screen.dart';
import 'package:cashier/halaman1/views/setting/edit_personal_info_screen.dart';
import 'package:cashier/halaman1/views/setting/help_center_screen.dart';
import 'package:cashier/halaman1/views/setting/language_screen.dart';
import 'package:cashier/halaman1/views/setting/notification_settings_screen.dart';
import 'package:cashier/halaman1/views/setting/privacy_policy_screen.dart';
import 'package:cashier/halaman1/views/setting/security_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> _handleLogout() async {
    final theme = AppTheme.instance;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: theme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.sourceSerif4(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun kasir Firebase ini?',
          style: GoogleFonts.workSans(color: theme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Batal',
              style: GoogleFonts.workSans(color: theme.outlineColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await FirebaseAuthService.instance.signOut();
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                debugPrint('Logout error: $e');
              }

              if (mounted) {
                context.pushAndRemoveAll(const cashierlogin1());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Keluar Akun'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader() {
    final theme = AppTheme.instance;
    final fbUser = FirebaseAuth.instance.currentUser;
    final data = UserDataStore.instance.userDataNotifier.value;

    final name = fbUser?.displayName ?? data['accountName'] ?? data['cashierName'] ?? 'Bella Gita Asmara';
    final email = fbUser?.email ?? data['email'] ?? 'kasir@bgaco.com';
    final role = data['accountRole'] ?? data['cashierRole'] ?? 'Senior Barista';
    final isVerified = fbUser?.emailVerified ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.surfaceContainerLow,
              border: Border.all(
                color: theme.secondaryColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: data['avatarBytes'] != null
                  ? Image.memory(data['avatarBytes'], fit: BoxFit.cover)
                  : Image.asset(
                      'assets/img/cat_mascot.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: theme.primaryColor,
                        size: 30,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isVerified)
                      Icon(
                        Icons.verified,
                        color: theme.secondaryColor,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    color: theme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.secondaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    role,
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push(const EditPersonalInfoScreen()),
            icon: Icon(Icons.edit_outlined, color: theme.secondaryColor, size: 20),
            tooltip: 'Edit Profil',
          ),
        ],
      ),
    );
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
            return ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: UserDataStore.instance.userDataNotifier,
              builder: (context, userData, _) {
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
                              // User Profile Header Card
                              _buildUserProfileHeader(),
                              const SizedBox(height: 20),

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
                              const SizedBox(height: 28),

                              // Logout Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: _handleLogout,
                                  icon: const Icon(Icons.logout, size: 20, color: Color(0xFFBA1A1A)),
                                  label: Text(
                                    'Keluar Akun Kasir (Logout)',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFBA1A1A),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Version Footer
                              Text(
                                'VERSION 1.2.4 • FIREBASE CLOUD',
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
