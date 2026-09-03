import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  // Visual preferences toggles
  bool _highContrast = false;
  bool _batterySaver = true;

  // Text size slider value: 0 (Small), 1 (Default), 2 (Large)
  double _textSizeValue = 1.0;

  @override
  void initState() {
    super.initState();
    final scale = AppTheme.instance.textScaleFactor;
    if (scale < 0.9) {
      _textSizeValue = 0.0;
    } else if (scale > 1.1) {
      _textSizeValue = 2.0;
    } else {
      _textSizeValue = 1.0;
    }
  }

  void _showSnackBar(String title) {
    final theme = AppTheme.instance;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title, style: GoogleFonts.workSans(color: Colors.white)),
        backgroundColor: theme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = AppTheme.instance;
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.workSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: theme.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required String themeKey,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.instance;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 130,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.secondaryColor
                  : theme.primaryColor.withValues(alpha: 0.1),
              width: isSelected ? 2.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(icon, size: 32, color: theme.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        color: theme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),

              // Checked Checkmark Indicator
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.check_circle,
                    size: 20,
                    color: theme.secondaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _getPreviewFontSize() {
    switch (_textSizeValue.round()) {
      case 0:
        return 13.0; // Small
      case 1:
        return 15.0; // Default
      case 2:
        return 18.0; // Large
      default:
        return 15.0;
    }
  }

  Widget _buildPaletteCard({
    required String paletteKey,
    required String title,
    required String description,
    required List<Color> swatchColors,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.instance;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.secondaryColor
                : theme.primaryColor.withValues(alpha: 0.1),
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: swatchColors
                    .map(
                      (c) => Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: theme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 22, color: theme.secondaryColor)
            else
              Icon(
                Icons.radio_button_unchecked,
                size: 22,
                color: theme.outlineColor,
              ),
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
      builder: (context, activeThemeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: theme.themePaletteNotifier,
          builder: (context, activePalette, child) {
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
                      onPressed: () => context.pop(activeThemeMode),
                    ),
                    title: Text(
                      loc.getText('appearance_title'),
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section 1: THEME MODE
                              _buildSectionHeader(
                                loc.getText('sec_theme_mode'),
                              ),
                              Row(
                                children: [
                                  _buildThemeCard(
                                    themeKey: 'light',
                                    icon: Icons.light_mode_outlined,
                                    title: loc.getText('theme_light'),
                                    isSelected: activeThemeMode == 'light',
                                    onTap: () async {
                                      await theme.setThemeMode('light');
                                      _showSnackBar(loc.getText('theme_light'));
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildThemeCard(
                                    themeKey: 'dark',
                                    icon: Icons.dark_mode_outlined,
                                    title: loc.getText('theme_dark'),
                                    isSelected: activeThemeMode == 'dark',
                                    onTap: () async {
                                      await theme.setThemeMode('dark');
                                      _showSnackBar(loc.getText('theme_dark'));
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildThemeCard(
                                    themeKey: 'system',
                                    icon: Icons.settings_brightness_outlined,
                                    title: loc.getText('theme_system'),
                                    subtitle: loc.getText('follow_device'),
                                    isSelected: activeThemeMode == 'system',
                                    onTap: () async {
                                      await theme.setThemeMode('system');
                                      _showSnackBar(
                                        loc.getText('theme_system'),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Section 1.5: PALET WARNA TEMA (Theme Color Palette)
                              _buildSectionHeader(
                                loc.getText('sec_color_palette'),
                              ),
                              Column(
                                children: [
                                  _buildPaletteCard(
                                    paletteKey: 'coffee',
                                    title: loc.getText('palette_coffee_title'),
                                    description: loc.getText(
                                      'palette_coffee_desc',
                                    ),
                                    swatchColors: const [
                                      Color(0xFF2C1A11),
                                      Color(0xFFD97706),
                                      Color(0xFFFEF3C7),
                                    ],
                                    isSelected: activePalette == 'coffee',
                                    onTap: () async {
                                      await theme.setThemePalette('coffee');
                                      _showSnackBar(
                                        loc.getText('palette_coffee_title'),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _buildPaletteCard(
                                    paletteKey: 'emerald',
                                    title: loc.getText('palette_emerald_title'),
                                    description: loc.getText(
                                      'palette_emerald_desc',
                                    ),
                                    swatchColors: const [
                                      Color(0xFF064E3B),
                                      Color(0xFF10B981),
                                      Color(0xFFD1FAE5),
                                    ],
                                    isSelected: activePalette == 'emerald',
                                    onTap: () async {
                                      await theme.setThemePalette('emerald');
                                      _showSnackBar(
                                        loc.getText('palette_emerald_title'),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _buildPaletteCard(
                                    paletteKey: 'berry',
                                    title: loc.getText('palette_berry_title'),
                                    description: loc.getText(
                                      'palette_berry_desc',
                                    ),
                                    swatchColors: const [
                                      Color(0xFF4C1D95),
                                      Color(0xFFE11D48),
                                      Color(0xFFFFE4E6),
                                    ],
                                    isSelected: activePalette == 'berry',
                                    onTap: () async {
                                      await theme.setThemePalette('berry');
                                      _showSnackBar(
                                        loc.getText('palette_berry_title'),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _buildPaletteCard(
                                    paletteKey: 'obsidian',
                                    title: loc.getText(
                                      'palette_obsidian_title',
                                    ),
                                    description: loc.getText(
                                      'palette_obsidian_desc',
                                    ),
                                    swatchColors: const [
                                      Color(0xFF0F172A),
                                      Color(0xFF6366F1),
                                      Color(0xFFE0E7FF),
                                    ],
                                    isSelected: activePalette == 'obsidian',
                                    onTap: () async {
                                      await theme.setThemePalette('obsidian');
                                      _showSnackBar(
                                        loc.getText('palette_obsidian_title'),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 36),

                              // Section 2: VISUAL PREFERENCES
                              _buildSectionHeader(
                                loc.getText('sec_visual_pref'),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.dividerColor,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Column(
                                    children: [
                                      // High Contrast Toggle
                                      ListTile(
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: theme.surfaceContainerLow,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.contrast,
                                            color: theme.primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          loc.getText('high_contrast_title'),
                                          style: GoogleFonts.workSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          loc.getText('high_contrast_desc'),
                                          style: GoogleFonts.workSans(
                                            fontSize: 13,
                                            color: theme.onSurfaceVariant,
                                          ),
                                        ),
                                        trailing: Switch(
                                          value: _highContrast,
                                          activeTrackColor: theme.secondaryColor
                                              .withValues(alpha: 0.3),
                                          activeThumbColor:
                                              theme.secondaryColor,
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor:
                                              theme.surfaceVariant,
                                          onChanged: (val) {
                                            setState(() => _highContrast = val);
                                            _showSnackBar(
                                              '${loc.getText("high_contrast_title")}: ${val ? loc.getText("status_on") : loc.getText("status_off")}',
                                            );
                                          },
                                        ),
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: theme.dividerColor,
                                      ),
                                      // Battery Saver Toggle
                                      ListTile(
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: theme.surfaceContainerLow,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.battery_saver,
                                            color: theme.primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          loc.getText('battery_saver_title'),
                                          style: GoogleFonts.workSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          loc.getText('battery_saver_desc'),
                                          style: GoogleFonts.workSans(
                                            fontSize: 13,
                                            color: theme.onSurfaceVariant,
                                          ),
                                        ),
                                        trailing: Switch(
                                          value: _batterySaver,
                                          activeTrackColor: theme.secondaryColor
                                              .withValues(alpha: 0.3),
                                          activeThumbColor:
                                              theme.secondaryColor,
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor:
                                              theme.surfaceVariant,
                                          onChanged: (val) {
                                            setState(() => _batterySaver = val);
                                            _showSnackBar(
                                              '${loc.getText("battery_saver_title")}: ${val ? loc.getText("status_on") : loc.getText("status_off")}',
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),

                              // Section 3: TEXT SIZE
                              _buildSectionHeader(loc.getText('sec_text_size')),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.dividerColor,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    // Text Size A Markers
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'A',
                                          style: GoogleFonts.workSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        Text(
                                          'A',
                                          style: GoogleFonts.sourceSerif4(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Slider
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: theme.secondaryColor,
                                        inactiveTrackColor:
                                            theme.surfaceVariant,
                                        thumbColor: theme.primaryColor,
                                        overlayColor: theme.secondaryColor
                                            .withValues(alpha: 0.2),
                                        valueIndicatorShape:
                                            const RectangularSliderValueIndicatorShape(),
                                      ),
                                      child: Slider(
                                        value: _textSizeValue,
                                        min: 0.0,
                                        max: 2.0,
                                        divisions: 2,
                                        onChanged: (val) {
                                          setState(() => _textSizeValue = val);
                                          double targetScale = 1.0;
                                          String sizeLabel = loc.getText(
                                            'size_default',
                                          );
                                          if (val == 0.0) {
                                            targetScale = 0.85;
                                            sizeLabel = loc.getText(
                                              'size_small',
                                            );
                                          } else if (val == 2.0) {
                                            targetScale = 1.18;
                                            sizeLabel = loc.getText(
                                              'size_large',
                                            );
                                          }
                                          AppTheme.instance.setTextScaleFactor(
                                            targetScale,
                                          );
                                          _showSnackBar(
                                            '${loc.getText("sec_text_size")}: $sizeLabel',
                                          );
                                        },
                                      ),
                                    ),

                                    // Small / Default / Large Labels
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          loc.getText('size_small'),
                                          style: GoogleFonts.workSans(
                                            fontSize: 12,
                                            color: theme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          loc.getText('size_default'),
                                          style: GoogleFonts.workSans(
                                            fontSize: 12,
                                            color: theme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          loc.getText('size_large'),
                                          style: GoogleFonts.workSans(
                                            fontSize: 12,
                                            color: theme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Live Preview Box
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: theme.dividerColor,
                                        ),
                                      ),
                                      child: Text(
                                        loc.getText('preview_quote'),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.sourceSerif4(
                                          fontSize: _getPreviewFontSize(),
                                          fontStyle: FontStyle.italic,
                                          height: 1.5,
                                          color: theme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
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
}
