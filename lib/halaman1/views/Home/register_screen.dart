import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/database/database_helper.dart';
import 'package:cashier/halaman1/models/user_login.dart';
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
    final email = emailC.text.trim();
    final phone = phoneC.text.trim();
    final city = cityC.text.trim();
    final pass = passwordC.text;
    final confirmPass = confirmPasswordC.text;

    if (pass != confirmPass) {
      _showSnackBar('Konfirmasi kata sandi tidak cocok!', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cashierId = email.contains('@')
          ? 'BG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
          : email;

      final newUser = UserModelSQL(
        nama: name,
        email: email,
        nomor_hp: phone,
        asalKota: city,
        password: pass,
        cashierId: cashierId,
        role: 'Barista / Kasir',
      );

      bool success = await DataBaseHelper().registerUser(newUser);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showSnackBar(
          'Pendaftaran berhasil! ID Kasir Anda: $cashierId',
          isError: false,
        );
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) {
          context.pop({'user': email, 'pass': pass});
        }
      } else {
        _showSnackBar(
          'Gagal mendaftar! Email / ID Kasir mungkin sudah terdaftar.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
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
      hintStyle: GoogleFonts.workSans(color: colorOutlineVariant, fontSize: 15),
      filled: true,
      fillColor: colorBackground,
      prefixIcon: Icon(prefixIcon, color: colorOutline, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: colorOutlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: colorSecondary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: colorOnErrorContainer, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: colorOnErrorContainer, width: 1.5),
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor),
              onPressed: () => context.pop(),
            ),
          ),
          body: Stack(
            children: [
              // Background Gradient
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Title
                          Text(
                            'DAFTAR AKUN',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.8,
                              color: colorPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Buat akun kasir baru BGA Co.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colorOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Lottie Logo
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorPrimary.withValues(alpha: 0.05),
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
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: colorOnSurface,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText:
                                          'contoh: KASIR02 / email@bga.com',
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
                                  _buildFieldLabel('Kata Sandi'),
                                  TextFormField(
                                    controller: passwordC,
                                    obscureText: _obscurePassword,
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: colorOnSurface,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: '••••••••',
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
                                      if (value.length < 3) {
                                        return 'Kata sandi minimal 3 karakter';
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
                                      hintText: '••••••••',
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
                                        return 'Kata sandi tidak sama';
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
                                                  'Daftar Akun',
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
