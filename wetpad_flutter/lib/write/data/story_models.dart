import 'dart:typed_data';

/// Data yang dikirim ke server saat membuat cerita
class StoryDraft {
  final String title;
  final String description;
  final Uint8List? coverBytes;

  const StoryDraft({
    required this.title,
    this.description = '',
    this.coverBytes,
  });
}

/// Cerita yang dikembalikan server
class Story {
  final int id;
  final String title;
  final String description;
  final String? coverUrl;
  final DateTime createdAt;

  const Story({
    required this.id,
    required this.title,
    required this.description,
    this.coverUrl,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> j) => Story(
    id: j['id'] as int,
    title: j['title'] as String,
    description: (j['description'] ?? '') as String,
    coverUrl: j['cover_url'] as String?,
    createdAt: DateTime.parse(j['created_at'] as String),
  );
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
