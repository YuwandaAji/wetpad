import 'package:flutter/material.dart';

class AppColors {
  static const orange = Color(0xFFFF5A12);
  static const tabBackground = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF222222);
  static const textSecondary = Color(0xFF8A8A8A);
  static const chip = Color(0xFFF0F0F0);
  static const sectionGap = Color(0xFFF3F3F3);
  static const border = Color(0xFFE3E3E3);
  static const followButton = Color(0xFFF2F2F2);
  static const link = Color(0xFF1E7B6E);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orange),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
      );
}
