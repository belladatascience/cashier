import 'dart:io';

import 'package:cashier/firebase_options.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/menu_data_store.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/Home/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:video_player_win/video_player_win.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi plugin khusus Windows desktop
  if (!kIsWeb && Platform.isWindows) {
    try {
      WindowsVideoPlayer.registerWith();
    } catch (e) {
      debugPrint('WindowsVideoPlayer initialization skipped/error: $e');
    }
  }

  // Format tanggal bahasa Indonesia
  await initializeDateFormatting("id_ID", null);

  // Inisialisasi Firebase Core & Cloud Firestore
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatformSafe,
    );
    debugPrint(
      'Firebase successfully initialized for project: ${DefaultFirebaseOptions.projectId}',
    );

    // Konfigurasi Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning/error: $e');
  }

  // Global Error Handler untuk Firebase & Flutter Framework
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(
      'Flutter/Firebase Unhandled Error: ${details.exceptionAsString()}',
    );
  };

  // Inisialisasi Data Stores Lokal & Sinkronisasi Sesi Firebase
  try {
    await MenuDataStore.instance.initFromDatabase();
    await UserDataStore.instance.initFromDatabase();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      debugPrint(
        'Active Firebase Session Detected: ${currentUser.email} (${currentUser.uid})',
      );
    }
  } catch (e) {
    debugPrint('DataStore initialization error: $e');
  }

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
                          child: childWidget ?? const SizedBox.shrink(),
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
