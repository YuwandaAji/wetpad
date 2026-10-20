import 'package:flutter/material.dart';

import '../../library/widgets/library_style.dart' as library_theme;

class AppColors {
  static const background = library_theme.LibColors.background;
  static const orange = library_theme.LibColors.orange;
  static const tabBackground = library_theme.LibColors.tabBar;
  static const textPrimary = Colors.white;
  static const textSecondary = library_theme.LibColors.textSecondary;
  static const chip = library_theme.LibColors.chip;
  static const sectionGap = library_theme.LibColors.background;
  static const border = library_theme.LibColors.border;
  static const followButton = library_theme.LibColors.sortPill;
  static const link = Color(0xFF1E7B6E);
}

class AppTheme {
  static ThemeData get dark => library_theme.libraryTheme();
}
