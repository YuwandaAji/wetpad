import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config_api.dart';
import 'story_models.dart';

/// Ganti ke false kalau backend sudah siap
const _useMock = false;

// Base URL backend (Ganti 10.0.2.2 dengan IP Laptop jika memakai HP fisik)
const _apiBaseUrl = 'http://127.0.0.1:8000/api';

final WriteRepository writeRepository = _useMock
    ? MockWriteRepository()
    : ApiWriteRepository(
        baseUrl: () => ApiConfig.base,
        tokenProvider: () => Session.token,
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

/// Implementasi REST API sungguhan (backend Laravel Wetpad)
class ApiWriteRepository implements WriteRepository {
  ApiWriteRepository({required this.baseUrl, required this.tokenProvider});

  final String Function() baseUrl;
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
    final req = http.MultipartRequest('POST', Uri.parse('${baseUrl()}/stories'))
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
    final data = _data(res);
    return Story.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<List<Story>> getMyStories() async {
    final res = await http
        .get(Uri.parse('${baseUrl()}/my/stories'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    final list = _data(res) as List<dynamic>;
    return list
        .map((e) => Story.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Backend membungkus hasil: { success, data, message }
  dynamic _data(http.Response res) {
    _check(res);
    final body = jsonDecode(res.body);
    return (body is Map && body.containsKey('data')) ? body['data'] : body;
  }

  void _check(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    var msg = 'Terjadi kesalahan (${res.statusCode})';
    try {
      final j = jsonDecode(res.body);
      final errs = j['errors'];
      if (errs is Map && errs.isNotEmpty) {
        final f = errs.values.first;
        msg = (f is List && f.isNotEmpty) ? '${f.first}' : '$f';
      } else {
        msg = (j['message'] as String?) ?? msg;
      }
    } catch (_) {}
    throw ApiException(msg, res.statusCode);
  }
}
