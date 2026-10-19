import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// Postingan di tab Percakapan. Sengaja tidak const karena balasan berubah.
class Post {
  final String id;
  final String authorId;
  final String authorName;
  final Color authorColor;
  final String text;
  final int minutesAgo;
  final List<Post> replies;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorColor,
    required this.text,
    required this.minutesAgo,
    List<Post>? replies,
  }) : replies = replies ?? [];

  String get timeAgo =>
      minutesAgo == 0 ? 'Baru saja' : timeAgoLabel(minutesAgo);
}
