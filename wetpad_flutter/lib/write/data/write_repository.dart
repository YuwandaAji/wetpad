import 'dart:convert';

import 'package:http/http.dart' as http;

import 'story_models.dart';

/// Ganti ke false kalau backend sudah siap
const _useMock = false;

// Base URL backend (Ganti 10.0.2.2 dengan IP Laptop jika memakai HP fisik)
const _apiBaseUrl = 'http://127.0.0.1:8000/api';

final WriteRepository writeRepository = _useMock
    ? MockWriteRepository()
    : ApiWriteRepository(
        baseUrl: _apiBaseUrl,
        // TODO: ganti dengan token dari Session, contoh: () => Session.token
        tokenProvider: () => null,
      );

abstract class WriteRepository {
  Future<Story> createStory(StoryDraft draft);
  Future<List<Story>> getMyStories();
}

/// Data palsu untuk development tanpa backend
class MockWriteRepository implements WriteRepository {
  final List<Story> _db = [];

  @override
  Future<Story> createStory(StoryDraft draft) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final story = Story(
      id: _db.length + 1,
      title: draft.title,
      description: draft.description,
      createdAt: DateTime.now(),
    );
    _db.add(story);
    return story;
  }

  @override
  Future<List<Story>> getMyStories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_db);
  }
}

/// Implementasi REST API sungguhan
class ApiWriteRepository implements WriteRepository {
  ApiWriteRepository({required this.baseUrl, required this.tokenProvider});

  final String baseUrl;
  final String? Function() tokenProvider;

  Map<String, String> get _headers {
    final token = tokenProvider();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Story> createStory(StoryDraft draft) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/stories'))
      ..headers.addAll(_headers)
      ..fields['title'] = draft.title
      ..fields['description'] = draft.description;

    if (draft.coverBytes != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          'cover',
          draft.coverBytes!,
          filename: 'cover.jpg',
        ),
      );
    }

    final res = await http.Response.fromStream(
      await req.send().timeout(const Duration(seconds: 30)),
    );
    _check(res);
    return Story.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  @override
  Future<List<Story>> getMyStories() async {
    final res = await http
        .get(Uri.parse('$baseUrl/stories/mine'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    _check(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Story.fromJson(e as Map<String, dynamic>)).toList();
  }

  void _check(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    var msg = 'Terjadi kesalahan (${res.statusCode})';
    try {
      msg = (jsonDecode(res.body)['message'] as String?) ?? msg;
    } catch (_) {}
    throw ApiException(msg, res.statusCode);
  }
}
