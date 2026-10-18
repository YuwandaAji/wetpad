import 'package:flutter/material.dart';

class SearchColors {
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF2A2A2A);
  static const tagBg = Color(0xFF1E1E1E);
  static const tagSelectedBg = Color(0xFF3A2A22);
  static const panel = Color(0xFF333333);
  static const panelChip = Color(0xFF454545);
  static const border = Color(0xFF3C3C3C);
  static const divider = Color(0xFF2E2E2E);
  static const accent = Color(0xFFFF6122);
  static const teal = Color(0xFF5BC8BE);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF9E9E9E);
  static const textTab = Color(0xFFB5B5B5);
}

/// Semua ukuran font ada di sini. Mau lebih kecil/besar? Ubah angkanya saja.
class SearchText {
  SearchText._();

  static const sectionTitle =
      TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800);
  static const screenTitle =
      TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800);

  static const storyTitle = TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif');
  static const rank = TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif');
  static const author =
      TextStyle(color: SearchColors.textSecondary, fontSize: 13);
  static const stat =
      TextStyle(color: SearchColors.textSecondary, fontSize: 12);
  static const tag = TextStyle(color: Color(0xFFE0E0E0), fontSize: 12);

  static const tab = TextStyle(
      color: SearchColors.textTab, fontSize: 14, fontWeight: FontWeight.w600);
  static const tabSelected =
      TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800);
  static const chip = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);

  static const input = TextStyle(color: Colors.white, fontSize: 14);
  static const hint =
      TextStyle(color: SearchColors.textSecondary, fontSize: 14);
  static const trending = TextStyle(color: Colors.white, fontSize: 15);
  static const caps = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5);

  static const label =
      TextStyle(color: SearchColors.textSecondary, fontSize: 13);
  static const body = TextStyle(color: Colors.white, fontSize: 14);
  static const button =
      TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700);
}
