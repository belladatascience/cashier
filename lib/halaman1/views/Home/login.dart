import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/services/firebase_auth_service.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/Home/Shop/home_screen.dart';
import 'package:cashier/halaman1/views/Home/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class cashierlogin1 extends StatefulWidget {
  const cashierlogin1({super.key});

  @override
  State<cashierlogin1> createState() => _cashierLogin1State();
}

class _cashierLogin1State extends State<cashierlogin1> {
  final TextEditingController cashierIdC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
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
    cashierIdC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  Future<void> _showSuccessAnimationAndNavigate(String cashierName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: colorSurfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorPrimary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Lottie Logo
                SizedBox(
                  height: 160,
                  child: Lottie.asset(
                    "assets/animation/cat_mascot.json",
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.check_circle_rounded,
                      size: 80,
                      color: colorSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Login Berhasil!',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selamat datang kembali, $cashierName!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Membuka Sistem Kasir...',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
      context.pushAndRemoveAll(const HomeScreen());
    }
  }

  void login() async {
    final user = cashierIdC.text.trim();
    final pass = passwordC.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      _showSnackBar('Harap isi ID Kasir / Email dan Kata Sandi!', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Login via Firebase Authentication Service
      final firebaseResult = await FirebaseAuthService.instance.loginUser(
        identifier: user,
        password: pass,
      );

      if (!mounted) return;

      if (firebaseResult['success'] == true) {
        final profile = firebaseResult['profile'] as Map<String, dynamic>? ?? {};
        final displayName = (profile['nama'] as String?)?.isNotEmpty == true
            ? profile['nama'] as String
            : (user.toLowerCase() == 'admin' ? 'Administrator' : 'Kasir');
        final displayEmail = (profile['email'] as String?) ?? user;
        final displayCashierId = (profile['cashierId'] as String?) ?? user;
        final displayPhone = (profile['nomor_hp'] as String?) ?? '087888848000';
        final displayRole = (profile['role'] as String?) ?? 'Barista / Kasir';

        await UserDataStore.instance.updateUserData({
          'userId': 1,
          'accountName': displayName,
          'cashierName': displayName,
          'email': displayEmail,
          'cashierId': displayCashierId,
          'phone': displayPhone,
          'accountRole': displayRole,
          'cashierRole': displayRole,
        });

        setState(() {
          _isLoading = false;
        });

        await _showSuccessAnimationAndNavigate(displayName);
      } else {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(
          firebaseResult['message'] ?? 'Login gagal! Periksa email/ID dan kata sandi.',
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

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: cashierIdC.text.contains('@') ? cashierIdC.text.trim() : '',
    );
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: colorSurfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Reset Kata Sandi Firebase',
              style: GoogleFonts.sourceSerif4(
                color: colorPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masukkan email akun kasir Anda. Link reset kata sandi akan dikirim langsung oleh Firebase ke email tersebut.',
                  style: GoogleFonts.workSans(
                    color: colorOnSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.workSans(color: colorOnSurface),
                  decoration: InputDecoration(
                    labelText: 'Alamat Email',
                    hintText: 'nama@domain.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSending ? null : () => Navigator.pop(dialogCtx),
                child: Text(
                  'Batal',
                  style: GoogleFonts.workSans(color: colorOutline),
                ),
              ),
              ElevatedButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          _showSnackBar('Masukkan format email yang valid!', isError: true);
                          return;
                        }

                        setDialogState(() => isSending = true);

                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                          _showSnackBar('Link reset kata sandi telah dikirim ke $email');
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() => isSending = false);
                          String err = 'Gagal mengirim email reset';
                          if (e.code == 'user-not-found') {
                            err = 'Email tidak terdaftar di Firebase.';
                          } else if (e.code == 'invalid-email') {
                            err = 'Format email tidak valid.';
                          }
                          _showSnackBar(err, isError: true);
                        } catch (e) {
                          setDialogState(() => isSending = false);
                          _showSnackBar('Error: $e', isError: true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: colorOnPrimaryContainer,
                ),
                child: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Kirim Link',
                        style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
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
              // Background Subtle Gradient Effect
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
                      vertical: 32.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Brand Icon & Header Title
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorSurfaceContainerLowest,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorPrimary.withValues(alpha: 0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/img/bga_bulat.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.storefront_outlined,
                                        size: 72,
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
                          const SizedBox(height: 28),

                          // Login Card Container
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
                            padding: const EdgeInsets.all(32.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ID Kasir Input Label
                                  Text(
                                    AppLocalization.instance.getText(
                                      'cashier_id_label',
                                    ),
                                    style: GoogleFonts.workSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.7,
                                      color: colorPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // ID Kasir Input Field
                                  TextFormField(
                                    controller: cashierIdC,
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: colorOnSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: AppLocalization.instance
                                          .getText('enter_id_hint'),
                                      hintStyle: GoogleFonts.workSans(
                                        color: colorOutlineVariant,
                                        fontSize: 16,
                                      ),
                                      filled: true,
                                      fillColor: colorBackground,
                                      prefixIcon: Icon(
                                        Icons.badge_outlined,
                                        color: colorOutline,
                                        size: 22,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 14,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          color: colorOutlineVariant,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          color: colorSecondary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Kata Sandi Input Label
                                  Text(
                                    AppLocalization.instance.getText(
                                      'password_label',
                                    ),
                                    style: GoogleFonts.workSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.7,
                                      color: colorPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Kata Sandi Input Field
                                  TextFormField(
                                    controller: passwordC,
                                    obscureText: _obscurePassword,
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: colorOnSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '•••••••••',
                                      hintStyle: GoogleFonts.workSans(
                                        color: colorOutlineVariant,
                                        fontSize: 16,
                                      ),
                                      filled: true,
                                      fillColor: colorBackground,
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: colorOutline,
                                        size: 22,
                                      ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 14,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          color: colorOutlineVariant,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          color: colorSecondary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Lupa Kata Sandi Link
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _showForgotPasswordDialog,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        AppLocalization.instance.getText(
                                          'forgot_password',
                                        ),
                                        style: GoogleFonts.workSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : login,
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
                                                  AppLocalization.instance
                                                      .getText('login_button'),
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
                                                  Icons.login,
                                                  size: 18,
                                                  color:
                                                      colorOnPrimaryContainer,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Register Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalization.instance.getText(
                                          'no_account',
                                        ),
                                        style: GoogleFonts.workSans(
                                          fontSize: 14,
                                          color: colorOnSurfaceVariant,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await context.push(
                                            const RegisterScreen(),
                                          );
                                          if (result != null && result is Map) {
                                            if (result['user'] != null) {
                                              cashierIdC.text = result['user']
                                                  .toString();
                                            }
                                            if (result['pass'] != null) {
                                              passwordC.text = result['pass']
                                                  .toString();
                                            }
                                          }
                                        },
                                        child: Text(
                                          AppLocalization.instance.getText(
                                            'register_now',
                                          ),
                                          style: GoogleFonts.workSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: colorSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Footer Copyright
                          Text(
                            '© 2026 BGA Co.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: colorOutline,
                            ),
                          ),
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
