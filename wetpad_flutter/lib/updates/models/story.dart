import 'package:flutter/material.dart';

class Story {
  final String id;
  final String title;
  final String author;
  final int reads;
  final int parts;
  final List<String> tags;
  final Color coverColor;
  final String coverText;
  final int stars;
  final String description;
  final String? rankLabel;

  const Story({
    required this.id,
    required this.title,
    required this.author,
    required this.reads,
    required this.parts,
    required this.tags,
    required this.coverColor,
    required this.coverText,
    this.stars = 0,
    this.description = '',
    this.rankLabel,
  });
}