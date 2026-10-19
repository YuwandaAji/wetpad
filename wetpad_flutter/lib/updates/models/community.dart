import 'package:flutter/material.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final int members;
  final Color color;
  final Color textColor;

  const Community({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.color,
    this.textColor = Colors.white,
  });

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}
