import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 🎨 Defines light and dark ThemeData for Yummate App
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.lightPrimary,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
    ),
    cardColor: AppColors.lightSurface,
    shadowColor: AppColors.lightShadow,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.lightText),
      titleTextStyle: TextStyle(
        color: AppColors.lightText,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.lightText, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: AppColors.lightText.withValues(alpha: 0.5)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        shadowColor: AppColors.lightShadow,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkPrimary,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
    ),
    cardColor: AppColors.darkSurface,
    shadowColor: AppColors.darkShadow,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.darkText),
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.darkText, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: AppColors.darkText.withValues(alpha: 0.5)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        shadowColor: AppColors.darkShadow,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}
