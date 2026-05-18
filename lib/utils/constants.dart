import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF2E4A9E);
  static const Color bgDark = Color(0xFFE8EDF5);
  static const Color bgMain = Color(0xFFF3F6FB);
  static const Color bgLight = Color(0xFFFDFEFE);
  static const Color textPrimary = Color(0xFF1A2340);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color borderMuted = Color(0xFFD8DEE9);
  static const Color success = Color(0xFF2E7D4F);
  static const Color warning = Color(0xFFB8860B);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF2563EB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = danger;
}

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.textMuted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
  );
}
