import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordC = TextEditingController();
  final TextEditingController newPasswordC = TextEditingController();
  final TextEditingController confirmPasswordC = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    newPasswordC.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    currentPasswordC.dispose();
    newPasswordC.dispose();
    confirmPasswordC.dispose();
    super.dispose();
  }

  // Password Requirements helper checks
  bool get _hasMinLength => newPasswordC.text.length >= 8;
  bool get _hasUppercase => newPasswordC.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => newPasswordC.text.contains(RegExp(r'[0-9]'));

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasMinLength || !_hasUppercase || !_hasNumber) {
      _showSnackBar(
        'Kata sandi baru harus memenuhi semua persyaratan keamanan!',
        isError: true,
      );
      return;
    }

    final currentPass = currentPasswordC.text.trim();
    final newPass = newPasswordC.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnackBar(
        'Sesi kasir tidak ditemukan. Harap login ulang terlebih dahulu.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = user.email;
      if (email != null && email.isNotEmpty) {
        // 1. Re-authenticate user with current password
        final cred = EmailAuthProvider.credential(
          email: email,
          password: currentPass,
        );
        await user.reauthenticateWithCredential(cred);
      }

      // 2. Update to new password in Firebase Auth
      await user.updatePassword(newPass);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        'Kata sandi Firebase berhasil diubah!',
        isError: false,
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        context.pop();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Gagal mengubah kata sandi.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Kata sandi saat ini salah. Periksa kembali!';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Kata sandi baru terlalu lemah untuk Firebase.';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'Sesi Anda telah kedaluwarsa. Silakan logout dan login ulang.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      }

      _showSnackBar(errorMessage, isError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    final theme = AppTheme.instance;

    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.workSans(
        color: theme.onSurfaceVariant,
        fontSize: 15,
      ),
      filled: true,
      fillColor: theme.surfaceColor,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.secondaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    final theme = AppTheme.instance;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildRequirementItem({required String label, required bool isMet}) {
    final theme = AppTheme.instance;

    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? Colors.green.shade600 : theme.outlineColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 13,
              color: isMet ? theme.primaryColor : theme.onSurfaceVariant,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
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

              // Top Header Sticky AppBar
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  loc.getText('change_password_title'),
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
                child: Column(
                  children: [
                    // Scrollable Form Fields
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 24.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Current Password Field
                                  _buildFieldLabel(
                                    loc.getText('current_password'),
                                  ),
                                  TextFormField(
                                    controller: currentPasswordC,
                                    obscureText: _obscureCurrentPassword,
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: loc.getText('current_password'),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureCurrentPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: theme.onSurfaceVariant,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureCurrentPassword =
                                                !_obscureCurrentPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return loc.getText('current_password');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // New Password Field
                                  _buildFieldLabel(loc.getText('new_password')),
                                  TextFormField(
                                    controller: newPasswordC,
                                    obscureText: _obscureNewPassword,
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: loc.getText('new_password'),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureNewPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: theme.onSurfaceVariant,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureNewPassword =
                                                !_obscureNewPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return loc.getText('new_password');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Confirm New Password Field
                                  _buildFieldLabel(
                                    loc.getText('confirm_new_password'),
                                  ),
                                  TextFormField(
                                    controller: confirmPasswordC,
                                    obscureText: _obscureConfirmPassword,
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: loc.getText(
                                        'confirm_new_password',
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: theme.onSurfaceVariant,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return loc.getText(
                                          'confirm_new_password',
                                        );
                                      }
                                      if (val != newPasswordC.text) {
                                        return loc.getText(
                                          'confirm_new_password',
                                        );
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),

                                  // Password Requirements Box
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.security_outlined,
                                              size: 18,
                                              color: theme.secondaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              loc.getText('password_req_title'),
                                              style: GoogleFonts.workSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _buildRequirementItem(
                                          label: loc.getText('req_min_length'),
                                          isMet: _hasMinLength,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildRequirementItem(
                                          label: loc.getText('req_uppercase'),
                                          isMet: _hasUppercase,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildRequirementItem(
                                          label: loc.getText('req_number'),
                                          isMet: _hasNumber,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Fixed Bottom Action Area
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        border: Border(
                          top: BorderSide(color: theme.dividerColor, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _savePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: theme.surfaceColor,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.surfaceColor,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      loc.getText('save_password_btn'),
                                      style: GoogleFonts.workSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
