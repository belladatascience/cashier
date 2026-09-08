import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cashier/firebase_options.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/menu_data_store.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/Home/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:video_player_win/video_player_win.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && Platform.isWindows) {
    WindowsVideoPlayer.registerWith();
  }
  await initializeDateFormatting("id_ID", null);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  await MenuDataStore.instance.initFromDatabase();
  await UserDataStore.instance.initFromDatabase();
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
          valueListenable: AppTheme.instance.themePaletteNotifier,
          builder: (context, paletteStr, child) {
            return ValueListenableBuilder<String>(
              valueListenable: AppLocalization.instance.currentLanguageNotifier,
              builder: (context, langCode, child) {
                return ValueListenableBuilder<double>(
                  valueListenable: AppTheme.instance.textScaleNotifier,
                  builder: (context, textScale, child) {
                    final theme = AppTheme.instance;
                    final isDark = theme.isDarkMode;

                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: 'BGA Co. Cashier',
                      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                      theme: ThemeData(
                        useMaterial3: true,
                        brightness: Brightness.light,
                        scaffoldBackgroundColor: theme.backgroundColor,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: theme.secondaryColor,
                          primary: theme.primaryColor,
                          secondary: theme.secondaryColor,
                          surface: theme.surfaceColor,
                          brightness: Brightness.light,
                        ),
                        cardTheme: CardThemeData(
                          color: theme.surfaceColor,
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        appBarTheme: AppBarTheme(
                          backgroundColor: theme.backgroundColor,
                          foregroundColor: theme.primaryColor,
                          elevation: 0,
                          scrolledUnderElevation: 0.5,
                        ),
                      ),
                      darkTheme: ThemeData(
                        useMaterial3: true,
                        brightness: Brightness.dark,
                        scaffoldBackgroundColor: theme.backgroundColor,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: theme.secondaryColor,
                          primary: theme.primaryColor,
                          secondary: theme.secondaryColor,
                          surface: theme.surfaceColor,
                          brightness: Brightness.dark,
                        ),
                        cardTheme: CardThemeData(
                          color: theme.surfaceColor,
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        appBarTheme: AppBarTheme(
                          backgroundColor: theme.backgroundColor,
                          foregroundColor: theme.primaryColor,
                          elevation: 0,
                          scrolledUnderElevation: 0.5,
                        ),
                      ),
                      builder: (context, childWidget) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(textScaler: TextScaler.linear(textScale)),
                          child: childWidget!,
                        );
                      },
                      home: const SplashScreen(),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
