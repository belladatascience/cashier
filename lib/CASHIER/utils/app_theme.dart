import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  AppTheme._internal() {
    _loadThemeMode();
  }

  static final AppTheme instance = AppTheme._internal();

  static const String _themeModeKey = 'app_theme_mode';
  static const String _textScaleKey = 'app_text_scale';
  static const String _themePaletteKey = 'app_theme_palette';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ValueNotifier holding current theme mode string: 'light', 'dark', 'system'
  final ValueNotifier<String> themeModeNotifier = ValueNotifier<String>(
    'light',
  );

  // ValueNotifier holding current color palette string: 'coffee', 'emerald', 'berry', 'obsidian'
  final ValueNotifier<String> themePaletteNotifier = ValueNotifier<String>(
    'coffee',
  );

  // ValueNotifier holding font scaling factor: 0.85 (Small), 1.0 (Default), 1.18 (Large)
  final ValueNotifier<double> textScaleNotifier = ValueNotifier<double>(1.0);

  String get currentThemeMode => themeModeNotifier.value;
  String get currentThemePalette => themePaletteNotifier.value;
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
    // 1. Fast load from local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);
      if (savedMode != null && ['light', 'dark', 'system'].contains(savedMode)) {
        themeModeNotifier.value = savedMode;
      }
      final savedPalette = prefs.getString(_themePaletteKey);
      if (savedPalette != null &&
          ['coffee', 'emerald', 'berry', 'obsidian'].contains(savedPalette)) {
        themePaletteNotifier.value = savedPalette;
      }
      final savedScale = prefs.getDouble(_textScaleKey);
      if (savedScale != null) {
        textScaleNotifier.value = savedScale;
      }
    } catch (_) {}

    // 2. Fetch and sync with Firebase Firestore
    await syncWithFirebase();
  }

  /// Sync theme settings from Cloud Firestore
  Future<void> syncWithFirebase() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          _applyThemeData(data);
          return;
        }
      }

      // Fallback global settings
      final globalDoc = await _firestore.collection('settings').doc('theme').get();
      if (globalDoc.exists && globalDoc.data() != null) {
        _applyThemeData(globalDoc.data()!);
      }
    } catch (e) {
      debugPrint('Firestore theme sync info: $e');
    }
  }

  void _applyThemeData(Map<String, dynamic> data) async {
    final mode = data['theme_mode'] as String?;
    final palette = data['theme_palette'] as String?;
    final scale = (data['text_scale'] as num?)?.toDouble();

    final prefs = await SharedPreferences.getInstance();

    if (mode != null && ['light', 'dark', 'system'].contains(mode)) {
      themeModeNotifier.value = mode;
      await prefs.setString(_themeModeKey, mode);
    }
    if (palette != null && ['coffee', 'emerald', 'berry', 'obsidian'].contains(palette)) {
      themePaletteNotifier.value = palette;
      await prefs.setString(_themePaletteKey, palette);
    }
    if (scale != null && scale > 0.5 && scale < 2.0) {
      textScaleNotifier.value = scale;
      await prefs.setDouble(_textScaleKey, scale);
    }
  }

  Future<void> setThemeMode(String mode, {String? userId}) async {
    if (['light', 'dark', 'system'].contains(mode)) {
      themeModeNotifier.value = mode;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themeModeKey, mode);
      } catch (_) {}
      _saveThemeToFirestore({'theme_mode': mode}, userId);
    }
  }

  Future<void> setThemePalette(String palette, {String? userId}) async {
    if (['coffee', 'emerald', 'berry', 'obsidian'].contains(palette)) {
      themePaletteNotifier.value = palette;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themePaletteKey, palette);
      } catch (_) {}
      _saveThemeToFirestore({'theme_palette': palette}, userId);
    }
  }

  Future<void> setTextScaleFactor(double scale, {String? userId}) async {
    textScaleNotifier.value = scale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_textScaleKey, scale);
    } catch (_) {}
    _saveThemeToFirestore({'text_scale': scale}, userId);
  }

  Future<void> _saveThemeToFirestore(Map<String, dynamic> data, String? userId) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      final payload = Map<String, dynamic>.from(data);
      payload['updatedAt'] = FieldValue.serverTimestamp();

      if (uid != null && uid.isNotEmpty) {
        await _firestore.collection('users').doc(uid).set(payload, SetOptions(merge: true));
      }

      await _firestore.collection('settings').doc('theme').set(payload, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore theme save error: $e');
    }
  }

  // Dynamic Theme Colors Palette System (Coffee Caramel, Emerald Matcha, Berry Velvet, Midnight Obsidian)
  Color get backgroundColor {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFF0B1713) : const Color(0xFFF3F9F5);
      case 'berry':
        return dark ? const Color(0xFF160D14) : const Color(0xFFFAF4F7);
      case 'obsidian':
        return dark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC);
      case 'coffee':
      default:
        return dark ? const Color(0xFF14110F) : const Color(0xFFFAF7F2);
    }
  }

  Color get surfaceColor {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFF13251F) : const Color(0xFFFFFFFF);
      case 'berry':
        return dark ? const Color(0xFF241421) : const Color(0xFFFFFFFF);
      case 'obsidian':
        return dark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);
      case 'coffee':
      default:
        return dark ? const Color(0xFF1F1A17) : const Color(0xFFFFFFFF);
    }
  }

  Color get surfaceContainerLow {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFF1A332B) : const Color(0xFFE6F4EA);
      case 'berry':
        return dark ? const Color(0xFF311C2C) : const Color(0xFFF7E6EB);
      case 'obsidian':
        return dark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9);
      case 'coffee':
      default:
        return dark ? const Color(0xFF27211D) : const Color(0xFFF3EEE6);
    }
  }

  Color get surfaceContainer {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFF234439) : const Color(0xFFD3EBDC);
      case 'berry':
        return dark ? const Color(0xFF42243A) : const Color(0xFFEFD3DC);
      case 'obsidian':
        return dark ? const Color(0xFF374151) : const Color(0xFFE2E8F0);
      case 'coffee':
      default:
        return dark ? const Color(0xFF332B26) : const Color(0xFFE9E1D5);
    }
  }

  Color get surfaceVariant {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFF2D5547) : const Color(0xFFBFDFCC);
      case 'berry':
        return dark ? const Color(0xFF542E4B) : const Color(0xFFE4BFCC);
      case 'obsidian':
        return dark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1);
      case 'coffee':
      default:
        return dark ? const Color(0xFF423832) : const Color(0xFFDCCFC0);
    }
  }

  Color get primaryColor {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFFECFDF5) : const Color(0xFF064E3B);
      case 'berry':
        return dark ? const Color(0xFFFDF2F8) : const Color(0xFF4C1D95);
      case 'obsidian':
        return dark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
      case 'coffee':
      default:
        return dark ? const Color(0xFFFDF8F3) : const Color(0xFF2C1A11);
    }
  }

  Color get secondaryColor {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFF34D399) : const Color(0xFF10B981);
      case 'berry':
        return dark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);
      case 'obsidian':
        return dark ? const Color(0xFF818CF8) : const Color(0xFF6366F1);
      case 'coffee':
      default:
        return dark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
    }
  }

  Color get secondaryContainer {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      case 'berry':
        return dark ? const Color(0xFF881337) : const Color(0xFFFFE4E6);
      case 'obsidian':
        return dark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF);
      case 'coffee':
      default:
        return dark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
    }
  }

  Color get onSecondaryContainer {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46);
      case 'berry':
        return dark ? const Color(0xFFFECDD3) : const Color(0xFF9F1239);
      case 'obsidian':
        return dark ? const Color(0xFFC7D2FE) : const Color(0xFF3730A3);
      case 'coffee':
      default:
        return dark ? const Color(0xFFFDE68A) : const Color(0xFF78350F);
    }
  }

  Color get onSurfaceColor {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFFECFDF5) : const Color(0xFF062D23);
      case 'berry':
        return dark ? const Color(0xFFFDF2F8) : const Color(0xFF2D1226);
      case 'obsidian':
        return dark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
      case 'coffee':
      default:
        return dark ? const Color(0xFFFDF8F3) : const Color(0xFF1F1610);
    }
  }

  Color get onSurfaceVariant {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFFA3CFC0) : const Color(0xFF366053);
      case 'berry':
        return dark ? const Color(0xFFD6B2C8) : const Color(0xFF6B455E);
      case 'obsidian':
        return dark ? const Color(0xFF9CA3AF) : const Color(0xFF475569);
      case 'coffee':
      default:
        return dark ? const Color(0xFFD1C2B7) : const Color(0xFF6B5B52);
    }
  }

  Color get outlineColor {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFF5E9181) : const Color(0xFF6E9E8E);
      case 'berry':
        return dark ? const Color(0xFF9E6E8F) : const Color(0xFFA67895);
      case 'obsidian':
        return dark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8);
      case 'coffee':
      default:
        return dark ? const Color(0xFF8C7A6E) : const Color(0xFFA89587);
    }
  }

  Color get outlineVariant {
    final dark = isDarkMode;
    switch (currentThemePalette) {
      case 'emerald':
        return dark ? const Color(0xFF28483D) : const Color(0xFFC7E5DA);
      case 'berry':
        return dark ? const Color(0xFF4C2742) : const Color(0xFFE5C8D8);
      case 'obsidian':
        return dark ? const Color(0xFF374151) : const Color(0xFFCBD5E1);
      case 'coffee':
      default:
        return dark ? const Color(0xFF4A3E37) : const Color(0xFFE2D6C7);
    }
  }

  Color get dividerColor {
    final dark = isDarkMode;
    return dark ? const Color(0x33FFFFFF) : const Color(0x1F000000);
  }
}
