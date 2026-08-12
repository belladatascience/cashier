import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();
  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.heading1,
      // bodyMedium: AppTextStyles.body,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.heading1,
      // bodyMedium: AppTextStyles.body,
    ),
  );
}
