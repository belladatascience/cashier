import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isSendingVerification = false;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettingsFromFirebase();
  }

  Future<void> _loadSecuritySettingsFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final secData = doc.data()!['security'] as Map<String, dynamic>?;
        if (secData != null && mounted) {
          setState(() {
            _is2faEnabled = secData['is2faEnabled'] ?? _is2faEnabled;
            _isBiometricEnabled = secData['isBiometricEnabled'] ?? _isBiometricEnabled;
          });
        }
      }
    } catch (e) {
      debugPrint('Firebase load security settings notice: $e');
    }
  }

  Future<void> _syncSecuritySettingsToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'security': {
          'is2faEnabled': _is2faEnabled,
          'isBiometricEnabled': _isBiometricEnabled,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firebase sync security settings error: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final theme = AppTheme.instance;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.workSans(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red.shade700 : theme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSendingVerification = true);
    try {
      await user.sendEmailVerification();
      _showSnackBar('Email verifikasi resmi Firebase telah dikirim ke ${user.email}!');
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Gagal mengirim verifikasi: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSendingVerification = false);
      }
    }
  }

  void _showLoginActivityBottomSheet() {
    final theme = AppTheme.instance;
    final loc = AppLocalization.instance;
    final user = FirebaseAuth.instance.currentUser;

    final creationDate = user?.metadata.creationTime != null
        ? '${user!.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}'
        : '2026';

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
                  child: Icon(Icons.cloud_done, color: theme.secondaryColor),
                ),
                title: Text(
                  'Sesi Firebase Authentication Aktif',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                subtitle: Text(
                  'UID: ${user?.uid ?? "Anonymous"} • Sesi Saat Ini',
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
                  'BGA POS App - Terminal Kasir',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                subtitle: Text(
                  'Akun Dibuat: $creationDate',
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
                  'BGA Co. POS Terminal #01 (Cloud Linked)',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                subtitle: Text(
                  'Perangkat Kasir Utama Toko',
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    color: theme.onSurfaceVariant,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('Perangkat terpercaya dikelola via Firebase Cloud');
                  },
                  child: Text(
                    'Kelola',
                    style: GoogleFonts.workSans(
                      color: theme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFirebaseAuthCard() {
    final theme = AppTheme.instance;
    final user = FirebaseAuth.instance.currentUser;
    final isVerified = user?.emailVerified ?? false;

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.secondaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.secondaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
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
                child: Icon(Icons.shield_outlined, color: theme.secondaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Keamanan Akun Firebase',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      user?.email ?? 'Kasir Terautentikasi',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: theme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                      : const Color(0xFFE65100).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isVerified ? 'Verified' : 'Unverified',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          if (!isVerified && user?.email != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Verifikasi email Anda untuk perlindungan akun maksimal.',
                    style: GoogleFonts.workSans(
                      fontSize: 12.5,
                      color: theme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: _isSendingVerification ? null : _sendEmailVerification,
                  child: _isSendingVerification
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Kirim Verifikasi',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.bold,
                            color: theme.secondaryColor,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ],
      ),
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
      children: [
        Row(
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
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.sourceSerif4(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
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
            icon: Icons.shield_outlined,
            title: loc.getText('two_factor_title'),
            iconBg: theme.surfaceContainerLow,
            iconColor: theme.primaryColor,
            trailingWidget: Switch(
              value: _is2faEnabled,
              activeTrackColor: theme.secondaryColor.withValues(alpha: 0.3),
              activeThumbColor: theme.secondaryColor,
              onChanged: (val) {
                setState(() {
                  _is2faEnabled = val;
                });
                _syncSecuritySettingsToFirebase();
                _showSnackBar(
                  '${loc.getText("two_factor_title")}: ${val ? loc.getText("status_on") : loc.getText("status_off")}',
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.getText('two_factor_desc'),
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
                color: theme.onSurfaceVariant,
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
      child: Column(
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
                _syncSecuritySettingsToFirebase();
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
                          _buildFirebaseAuthCard(),
                          const SizedBox(height: 16),
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
