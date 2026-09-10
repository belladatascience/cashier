import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/database/database_helper.dart';
import 'package:cashier/halaman1/models/user_login.dart';
import 'package:cashier/halaman1/services/firebase_auth_service.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  final TextEditingController cityC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmPasswordC = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Dynamic Color Tokens linked to AppTheme
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorPrimaryContainer => AppTheme.instance.primaryColor;
  Color get colorOnPrimaryContainer => AppTheme.instance.surfaceColor;
  Color get colorSecondary => AppTheme.instance.secondaryColor;
  Color get colorBackground => AppTheme.instance.backgroundColor;
  Color get colorSurfaceContainerLowest => AppTheme.instance.surfaceColor;
  Color get colorSurfaceContainerHighest =>
      AppTheme.instance.surfaceContainerLow;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;
  Color get colorOutline => AppTheme.instance.outlineColor;
  Color get colorOnSurface => AppTheme.instance.onSurfaceColor;
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;
  Color get colorErrorContainer => AppTheme.instance.isDarkMode
      ? const Color(0xFF501010)
      : const Color(0xFFFFDAD6);
  Color get colorOnErrorContainer => const Color(0xFF93000A);

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    cityC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameC.text.trim();
    String rawEmailOrId = emailC.text.trim();
    final phone = phoneC.text.trim();
    final city = cityC.text.trim();
    final pass = passwordC.text;
    final confirmPass = confirmPasswordC.text;

    if (pass != confirmPass) {
      _showSnackBar('Konfirmasi kata sandi tidak cocok!', isError: true);
      return;
    }

    if (pass.length < 6) {
      _showSnackBar('Kata sandi minimal 6 karakter untuk Firebase!', isError: true);
      return;
    }

    // Auto-normalize email format for Firebase Auth if user inputs ID like "KASIR01"
    String normalizedEmail = rawEmailOrId;
    String assignedCashierId = rawEmailOrId;

    if (!rawEmailOrId.contains('@')) {
      final sanitized = rawEmailOrId.toLowerCase().replaceAll(' ', '');
      normalizedEmail = '$sanitized@bgaco.com';
      assignedCashierId = rawEmailOrId.toUpperCase();
    } else {
      assignedCashierId = 'BG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Register with Firebase Authentication & Cloud Firestore
      final result = await FirebaseAuthService.instance.registerUser(
        name: name,
        email: normalizedEmail,
        password: pass,
        phone: phone,
        city: city,
        cashierId: assignedCashierId,
        role: 'Barista / Kasir',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final finalCashierId = result['cashierId'] ?? assignedCashierId;

        // 2. Synchronize to local SQLite for offline resilience
        try {
          final newUser = UserModelSQL(
            nama: name,
            email: normalizedEmail,
            nomor_hp: phone,
            asalKota: city,
            password: pass,
            cashierId: finalCashierId,
            role: 'Barista / Kasir',
          );
          await DataBaseHelper().registerUser(newUser);
        } catch (dbErr) {
          debugPrint('Local SQLite sync note: $dbErr');
        }

        setState(() {
          _isLoading = false;
        });

        _showSnackBar(
          'Pendaftaran Firebase berhasil! ID Kasir Anda: $finalCashierId',
          isError: false,
        );

        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          context.pop({'user': rawEmailOrId, 'pass': pass});
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(
          result['message'] ?? 'Gagal mendaftar ke Firebase!',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Terjadi kesalahan pendaftaran: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.workSans(
            color: isError ? colorOnErrorContainer : colorPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError
            ? colorErrorContainer
            : colorOnPrimaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.workSans(
        color: colorOutlineVariant,
        fontSize: 14,
      ),
      filled: true,
      fillColor: colorBackground,
      prefixIcon: Icon(prefixIcon, color: colorOutline, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorOutlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorSecondary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorErrorContainer,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorErrorContainer,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: colorPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: Stack(
            children: [
              // Subtle Ambient Radial Gradient Background
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Color.fromRGBO(231, 189, 177, 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Back Button & Title
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: colorPrimary,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: colorSurfaceContainerLowest,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Daftar Akun Firebase',
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: colorPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Header Animated Avatar / Logo
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorSurfaceContainerLowest,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorPrimary.withValues(
                                      alpha: 0.12,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Lottie.asset(
                                  "assets/animation/cafe.json",
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.person_add_alt_1_outlined,
                                        size: 52,
                                        color: colorPrimary.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Register Card Container
                          Container(
                            decoration: BoxDecoration(
                              color: colorSurfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorSurfaceContainerHighest,
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(68, 42, 34, 0.12),
                                  blurRadius: 30,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(28.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nama Lengkap
                                  _buildFieldLabel('Nama Lengkap'),
                                  TextFormField(
                                    controller: nameC,
                                    textCapitalization: TextCapitalization.words,
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: colorOnSurface,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: 'Masukkan nama lengkap',
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Nama lengkap wajib diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Email / ID Kasir
                                  _buildFieldLabel('Email / ID Kasir'),
                                  TextFormField(
                                    controller: emailC,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: colorOnSurface,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText:
                                          'contoh: KASIR02 atau email@bga.com',
                                      prefixIcon: Icons.badge_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Email / ID Kasir wajib diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Nomor HP
                                  _buildFieldLabel('Nomor HP'),
                                  TextFormField(
                                    controller: phoneC,
                                    keyboardType: TextInputType.phone,
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: colorOnSurface,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: '08123456789',
                                      prefixIcon: Icons.phone_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Nomor HP wajib diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Asal Kota
                                  _buildFieldLabel('Asal Kota'),
                                  TextFormField(
                                    controller: cityC,
                                    textCapitalization: TextCapitalization.words,
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: colorOnSurface,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: 'Masukkan asal kota',
                                      prefixIcon: Icons.location_city_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Asal kota wajib diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Kata Sandi
                                  _buildFieldLabel('Kata Sandi (Min. 6 Karakter)'),
                                  TextFormField(
                                    controller: passwordC,
                                    obscureText: _obscurePassword,
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: colorOnSurface,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: '•••••••••',
                                      prefixIcon: Icons.lock_outline,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: colorOutline,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Kata sandi wajib diisi';
                                      }
                                      if (value.length < 6) {
                                        return 'Kata sandi minimal 6 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Konfirmasi Kata Sandi
                                  _buildFieldLabel('Konfirmasi Kata Sandi'),
                                  TextFormField(
                                    controller: confirmPasswordC,
                                    obscureText: _obscureConfirmPassword,
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: colorOnSurface,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: '•••••••••',
                                      prefixIcon: Icons.lock_reset_outlined,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: colorOutline,
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Konfirmasi kata sandi wajib diisi';
                                      }
                                      if (value != passwordC.text) {
                                        return 'Konfirmasi kata sandi tidak sesuai';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Submit Register Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorPrimaryContainer,
                                        foregroundColor:
                                            colorOnPrimaryContainer,
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: colorOnPrimaryContainer,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Daftar Akun Firebase',
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.7,
                                                    color:
                                                        colorOnPrimaryContainer,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
                                                  Icons.app_registration,
                                                  size: 18,
                                                  color:
                                                      colorOnPrimaryContainer,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Navigation back to Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: GoogleFonts.workSans(
                                  fontSize: 14,
                                  color: colorOnSurfaceVariant,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Text(
                                  'Masuk Sekarang',
                                  style: GoogleFonts.workSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colorSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
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
}
