import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F9488);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color primarySoft = Color(0xFFE6FAF6);

  static const Color bg = Color(0xFFF6F7F9);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFF7ED);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color info = Color(0xFF3B82F6);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'PingFang SC',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );
}

class AppRadius {
  static const double card = 8;
  static const double pill = 999;
  static const double chip = 8;
  static const double input = 8;
}
