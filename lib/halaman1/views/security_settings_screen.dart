import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _is2faEnabled = true;
  bool _isBiometricEnabled = true;

  void _showSnackBar(String message) {
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

  void _showLoginActivityBottomSheet() {
    final theme = AppTheme.instance;
    final loc = AppLocalization.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.getText('login_activity_title'),
                style: GoogleFonts.sourceSerif4(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.laptop_mac, color: theme.primaryColor),
                ),
                title: Text(
                  'macOS - Chrome Browser',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                subtitle: Text(
                  'Jakarta, Indonesia • Sesi Saat Ini',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: theme.onSurfaceVariant,
                  ),
                ),
                trailing: Text(
                  'Aktif',
                  style: GoogleFonts.workSans(
                    color: theme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone_iphone, color: theme.primaryColor),
                ),
                title: Text(
                  'iPhone 14 Pro - POS App',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                subtitle: Text(
                  'Jakarta, Indonesia • 2 jam yang lalu',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: theme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTrustedDevicesBottomSheet() {
    final theme = AppTheme.instance;
    final loc = AppLocalization.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.getText('trusted_devices_title'),
                style: GoogleFonts.sourceSerif4(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.verified_user, color: theme.secondaryColor),
                title: Text(
                  'BGA Co. POS Terminal #01',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                subtitle: Text(
                  'Ditambahkan pada 10 Aug 2026',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: theme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    required Color iconBg,
    required Color iconColor,
    required Widget trailingWidget,
  }) {
    final theme = AppTheme.instance;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailingWidget,
      ],
    );
  }

  Widget _build2FaCard() {
    final theme = AppTheme.instance;
    final loc = AppLocalization.instance;

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.vpn_key_outlined,
            title: loc.getText('two_fa_title'),
            iconBg: theme.surfaceContainerLow,
            iconColor: theme.primaryColor,
            trailingWidget: Switch(
              value: _is2faEnabled,
              activeTrackColor: theme.secondaryContainer,
              activeThumbColor: theme.secondaryColor,
              onChanged: (val) {
                setState(() {
                  _is2faEnabled = val;
                });
                _showSnackBar(
                  '${loc.getText("two_fa_title")}: ${val ? loc.getText("status_on") : loc.getText("status_off")}',
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.getText('two_fa_desc'),
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: theme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              text: '${loc.getText("status_label")}: ',
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: theme.outlineColor,
              ),
              children: [
                TextSpan(
                  text: _is2faEnabled
                      ? loc.getText('status_on')
                      : loc.getText('status_off'),
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    color: _is2faEnabled
                        ? theme.secondaryColor
                        : theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricCard() {
    final theme = AppTheme.instance;
    final loc = AppLocalization.instance;

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.secondaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(
                icon: Icons.fingerprint,
                title: loc.getText('biometric_title'),
                iconBg: theme.secondaryContainer,
                iconColor: theme.onSecondaryContainer,
                trailingWidget: Switch(
                  value: _isBiometricEnabled,
                  activeTrackColor: theme.secondaryContainer,
                  activeThumbColor: theme.secondaryColor,
                  onChanged: (val) {
                    setState(() {
                      _isBiometricEnabled = val;
                    });
                    _showSnackBar(
                      '${loc.getText("biometric_title")}: ${val ? loc.getText("status_on") : loc.getText("status_off")}',
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.getText('biometric_desc'),
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: theme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: '${loc.getText("status_label")}: ',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: theme.secondaryColor,
                  ),
                  children: [
                    TextSpan(
                      text: _isBiometricEnabled
                          ? loc.getText('status_on')
                          : loc.getText('status_off'),
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.bold,
                        color: theme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClickableCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.instance;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: theme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.outlineColor, size: 22),
          ],
        ),
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
            return Scaffold(
              backgroundColor: theme.backgroundColor,

              // Top Sticky Header
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  loc.getText('security_title'),
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
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
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        children: [
                          _build2FaCard(),
                          const SizedBox(height: 16),
                          _buildBiometricCard(),
                          const SizedBox(height: 16),
                          _buildClickableCard(
                            icon: Icons.history,
                            title: loc.getText('login_activity_title'),
                            description: loc.getText('login_activity_desc'),
                            onTap: _showLoginActivityBottomSheet,
                          ),
                          const SizedBox(height: 16),
                          _buildClickableCard(
                            icon: Icons.devices,
                            title: loc.getText('trusted_devices_title'),
                            description: loc.getText('trusted_devices_desc'),
                            onTap: _showTrustedDevicesBottomSheet,
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
      },
    );
  }
}
