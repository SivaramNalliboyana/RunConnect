import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onBackground,
    letterSpacing: -0.5,
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
  );

  static const bodyMuted = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
    letterSpacing: 0.2,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
