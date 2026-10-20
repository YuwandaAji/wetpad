import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// Postingan di tab Percakapan. Sengaja tidak const karena balasan berubah.
class Post {
    factory Post.fromJson(Map<String, dynamic> j) {
    final name = j['author'] as String;
    final seed = name.codeUnits.fold<int>(0, (a, b) => a + b);
    const palette = [
      Color(0xFF3B4A8C), Color(0xFF2E5E4E), Color(0xFFB4410B),
      Color(0xFF5B2A86), Color(0xFFD6336C),
    ];
    final created = DateTime.parse(j['created_at'] as String).toLocal();
    return Post(
      id: j['id'] as String,
      authorId: 'user_$name',
      authorName: name,
      authorColor: palette[seed % palette.length],
      text: j['body'] as String,
      minutesAgo: DateTime.now().difference(created).inMinutes.clamp(0, 1 << 30),
      replies: [
        for (final r in (j['replies'] as List? ?? const []))
          Post.fromJson(Map<String, dynamic>.from(r)),
      ],
    );
  }
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
