import 'package:flutter/material.dart';

/// Model data novel untuk fitur Home
class Novel {
  final int id;
  final String title;
  final String author;
  final String synopsis;
  final String coverUrl;
  final String? assetFallback;
  final List<String> tags;
  final String reads;
  final String votes;
  final int parts;
  final bool isCompleted;
  final Color accentColor;

  const Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.synopsis,
    required this.coverUrl,
    this.assetFallback,
    required this.tags,
    required this.reads,
    required this.votes,
    required this.parts,
    this.isCompleted = false,
    this.accentColor = const Color(0xFF00ADB5),
  });
}
