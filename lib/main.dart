import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/views/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("id_ID", null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTheme.instance.themeModeNotifier,
      builder: (context, themeModeStr, child) {
        return ValueListenableBuilder<String>(
          valueListenable: AppLocalization.instance.currentLanguageNotifier,
          builder: (context, langCode, child) {
            return ValueListenableBuilder<double>(
              valueListenable: AppTheme.instance.textScaleNotifier,
              builder: (context, textScale, child) {
                final isDark = AppTheme.instance.isDarkMode;

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'BGA Co. Cashier',
                  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                  theme: ThemeData(
                    useMaterial3: true,
                    brightness: Brightness.light,
                    scaffoldBackgroundColor: const Color(0xFFFAFAF5),
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: const Color(0xFF7D562D),
                      brightness: Brightness.light,
                      surface: const Color(0xFFFAFAF5),
                    ),
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: const Color(0xFF1C1B1A),
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: const Color(0xFFF0BD8B),
                      brightness: Brightness.dark,
                      surface: const Color(0xFF2A2826),
                    ),
                  ),
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(textScale),
                      ),
                      child: childWidget!,
                    );
                  },
                  home: const cashierlogin1(),
                );
              },
            );
          },
        );
      },
    );
  }
}
