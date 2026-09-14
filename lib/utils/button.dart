// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColor {
  AppColor._();

  static const Color blueButton = Color(0xFF534138); // BGA Co. Signature Latte / Brown
  static const Color greyColorDivider = Color(0xFFE0E0E0);
}

/// Tombol default aplikasi dengan dukungan loading Firebase & tema dinamis
class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key,
    this.onPressed,
    required this.text,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.icon,
    this.height = 54,
    this.borderRadius = 10,
  });

  final VoidCallback? onPressed;
  final String text;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;
    final buttonBg = color ?? theme.secondaryColor;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBg,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: buttonBg.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: textColor ?? Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Tombol Outline dengan Icon untuk integrasi pihak ketiga / Firebase Social Auth
class ButtonWithIcon extends StatelessWidget {
  const ButtonWithIcon({
    super.key,
    required this.text,
    required this.image,
    this.onPressed,
    this.isLoading = false,
    this.height = 48,
    this.isNetworkImage = false,
  });

  final String text;
  final String image;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final bool isNetworkImage;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(width: 1.2, color: theme.outlineColor),
          backgroundColor: theme.surfaceColor,
          foregroundColor: theme.onSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.secondaryColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isNetworkImage)
                    Image.network(
                      image,
                      height: 22,
                      width: 22,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.cloud_queue,
                        color: theme.secondaryColor,
                        size: 22,
                      ),
                    )
                  else
                    Image.asset(
                      image,
                      height: 22,
                      width: 22,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.lock_outline,
                        color: theme.secondaryColor,
                        size: 22,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.onSurfaceColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Tombol Khusus Operasi Asynchronous Firebase (Auth / Firestore Write / Cloud Sync)
/// Otomatis menangani indikator loading dan penanganan exception Firebase
class FirebaseAsyncButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onAsyncPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final String? analyticsActionName;

  const FirebaseAsyncButton({
    super.key,
    required this.text,
    required this.onAsyncPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height = 54,
    this.borderRadius = 10,
    this.analyticsActionName,
  });

  @override
  State<FirebaseAsyncButton> createState() => _FirebaseAsyncButtonState();
}

class _FirebaseAsyncButtonState extends State<FirebaseAsyncButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (widget.analyticsActionName != null) {
        final user = FirebaseAuth.instance.currentUser;
        try {
          await FirebaseFirestore.instance.collection('button_analytics').add({
            'action': widget.analyticsActionName,
            'uid': user?.uid ?? 'guest',
            'email': user?.email ?? 'anonymous',
            'timestamp': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      }

      await widget.onAsyncPressed();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultButton(
      text: widget.text,
      onPressed: _handlePress,
      isLoading: _isLoading,
      color: widget.backgroundColor,
      textColor: widget.textColor,
      icon: widget.icon,
      height: widget.height,
      borderRadius: widget.borderRadius,
    );
  }
}
