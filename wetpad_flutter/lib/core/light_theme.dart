import 'package:flutter/material.dart';

import 'theme.dart';

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    fontFamily: 'SourceSans3', // samakan dengan font di appTheme()
    colorScheme: ColorScheme.fromSeed(
      seedColor: kOrange,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    dividerColor: const Color(0xFFE0E0E0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );
}
