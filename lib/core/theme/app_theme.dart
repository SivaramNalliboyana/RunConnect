import 'package:flutter/material.dart';
import 'app_colors.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Lexend',
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    surface: AppColors.surface,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onSurface: AppColors.onBackground,
    error: AppColors.error,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.onBackground,
    elevation: 0,
    centerTitle: false,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
    ),
    hintStyle: const TextStyle(color: AppColors.textMuted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
);
