
import 'package:flutter/material.dart';

const kBg = Color(0xFF121212);
const kDivider = Color(0xFF2A2A2A);
const kOrange = Color(0xFFFF6122);
const kGreyField = Color(0xFF1E1E1E);

class AppColors {
  static const bg = Color(0xFF121212);
  static const orange = Color(0xFFFF6122);
  static const chip = Color(0xFF2B2B2B);
  static const muted = Color(0xFFA0A0A0);
  static const premiumBg = Color(0xFF33324A);
  static const lavender = Color(0xFFA99AE6);
}

ThemeData appTheme() => ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.bg,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.orange,
    surface: AppColors.bg,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.bg,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
  ),
);
