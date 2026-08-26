import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageOption {
  final String title;
  final String subtitle;
  final String code;

  const LanguageOption({
    required this.title,
    required this.subtitle,
    required this.code,
  });
}

class LanguageScreen extends StatefulWidget {
  final String currentLanguage;

  const LanguageScreen({super.key, this.currentLanguage = 'English'});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedCode;

  final List<LanguageOption> _options = const [
    LanguageOption(title: 'English', subtitle: 'Default', code: 'en'),
    LanguageOption(
      title: 'Bahasa Indonesia',
      subtitle: 'Indonesian',
      code: 'id',
    ),
    LanguageOption(title: '中文', subtitle: 'Mandarin (Simplified)', code: 'zh'),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize selected code from the localization notifier
    _selectedCode = AppLocalization.instance.currentLanguageNotifier.value;
  }

  void _saveLanguagePreference() async {
    await AppLocalization.instance.setLanguage(_selectedCode);
    final theme = AppTheme.instance;

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalization.instance.getText("saved")}: ${AppLocalization.instance.currentLanguageName}',
            style: GoogleFonts.workSans(color: Colors.white),
          ),
          backgroundColor: theme.secondaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      context.pop(_selectedCode);
    }
  }

  Widget _buildLanguageCard(LanguageOption option) {
    final theme = AppTheme.instance;
    final isSelected = _selectedCode == option.code;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.secondaryColor : theme.dividerColor,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCode = option.code;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Radio<String>(
                value: option.code,
                groupValue: _selectedCode,
                activeColor: theme.secondaryColor,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCode = value;
                    });
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: theme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: theme.secondaryColor, size: 20),
            ],
          ),
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
                  loc.getText('language_title'),
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
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 24.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 540),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Subtitle Description
                                Text(
                                  loc.getText('language_subtitle'),
                                  style: GoogleFonts.workSans(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: theme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Radio Options Cards
                                ..._options.map(_buildLanguageCard),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Fixed Bottom Save Action Bar
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        border: Border(
                          top: BorderSide(color: theme.dividerColor, width: 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 540),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _saveLanguagePreference,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: theme.surfaceColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                loc.getText('save_changes'),
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
