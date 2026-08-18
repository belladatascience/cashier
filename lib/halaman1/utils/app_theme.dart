import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  AppTheme._internal() {
    _loadThemeMode();
  }

  static final AppTheme instance = AppTheme._internal();

  static const String _themeModeKey = 'app_theme_mode';
  static const String _textScaleKey = 'app_text_scale';

  // ValueNotifier holding current theme mode string: 'light', 'dark', 'system'
  final ValueNotifier<String> themeModeNotifier =
      ValueNotifier<String>('light');

  // ValueNotifier holding font scaling factor: 0.85 (Small), 1.0 (Default), 1.18 (Large)
  final ValueNotifier<double> textScaleNotifier = ValueNotifier<double>(1.0);

  String get currentThemeMode => themeModeNotifier.value;
  double get textScaleFactor => textScaleNotifier.value;

  bool get isDarkMode {
    if (themeModeNotifier.value == 'dark') return true;
    if (themeModeNotifier.value == 'system') {
      final window = WidgetsBinding.instance.platformDispatcher;
      return window.platformBrightness == Brightness.dark;
    }
    return false;
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);
    if (savedMode != null && ['light', 'dark', 'system'].contains(savedMode)) {
      themeModeNotifier.value = savedMode;
    }
    final savedScale = prefs.getDouble(_textScaleKey);
    if (savedScale != null) {
      textScaleNotifier.value = savedScale;
    }
  }

  Future<void> setThemeMode(String mode) async {
    if (['light', 'dark', 'system'].contains(mode)) {
      themeModeNotifier.value = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode);
    }
  }

  Future<void> setTextScaleFactor(double scale) async {
    textScaleNotifier.value = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, scale);
  }

  // Dynamic Theme Colors Palette (BGA Co. Coffee Warm Palette vs Dark Mocha Palette)
  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF1C1B1A) : const Color(0xFFFAFAF5);

  Color get surfaceColor =>
      isDarkMode ? const Color(0xFF2A2826) : const Color(0xFFFFFFFF);

  Color get surfaceContainerLow =>
      isDarkMode ? const Color(0xFF242220) : const Color(0xFFF4F4EF);

  Color get surfaceContainer =>
      isDarkMode ? const Color(0xFF32302D) : const Color(0xFFEEEEE9);

  Color get surfaceVariant =>
      isDarkMode ? const Color(0xFF3B3835) : const Color(0xFFE2E3DE);

  Color get primaryColor =>
      isDarkMode ? const Color(0xFFF5EFEA) : const Color(0xFF303030);

  Color get secondaryColor =>
      isDarkMode ? const Color(0xFFF0BD8B) : const Color(0xFF7D562D);

  Color get secondaryContainer =>
      isDarkMode ? const Color(0xFF623F18) : const Color(0xFFFFCA98);

  Color get onSecondaryContainer =>
      isDarkMode ? const Color(0xFFFFDCBD) : const Color(0xFF7A532A);

  Color get onSurfaceColor =>
      isDarkMode ? const Color(0xFFF5EFEA) : const Color(0xFF1A1C19);

  Color get onSurfaceVariant =>
      isDarkMode ? const Color(0xFFD4C3BE) : const Color(0xFF504441);

  Color get outlineColor =>
      isDarkMode ? const Color(0xFF9E8E89) : const Color(0xFF827470);

  Color get outlineVariant =>
      isDarkMode ? const Color(0xFF534542) : const Color(0xFFD4C3BE);

  Color get dividerColor =>
      isDarkMode ? const Color(0xFF3B3835) : const Color(0x1A303030);
}
