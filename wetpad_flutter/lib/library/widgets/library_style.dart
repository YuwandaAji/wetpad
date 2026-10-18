import 'package:flutter/material.dart';

class LibColors {
  static const background = Color(0xFF121212);
  static const tabBar = Color(0xFF1E1E1E);
  static const orange = Color(0xFFFF6122);
  static const textSecondary = Color(0xFF9E9E9E);
  static const chip = Color(0xFF2A2A2A);
  static const sortPill = Color(0xFF262626);
  static const border = Color(0xFF3A3A3A);
  static const dialog = Color(0xFF424242);
  static const likedTile = Color(0xFF7B4B3A);
  static const placeholderBox = Color(0xFF2E2E2E);
}

const kLibraryFont = 'SourceSans3';
ThemeData libraryTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: kLibraryFont,
      scaffoldBackgroundColor: LibColors.background,
      colorScheme: const ColorScheme.dark(
          primary: LibColors.orange, surface: LibColors.background),
      appBarTheme: const AppBarTheme(
        backgroundColor: LibColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontFamily: kLibraryFont,
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700),
      ),
      popupMenuTheme: const PopupMenuThemeData(
          color: LibColors.dialog, surfaceTintColor: Colors.transparent),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: LibColors.tabBar,
          surfaceTintColor: Colors.transparent),
      dividerColor: LibColors.border,
    );
