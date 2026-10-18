
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config_api.dart';
import '../data/sci_fi_story_content.dart';
import '../models/story.dart';
import '../models/part.dart';
import '../models/comment.dart';

class ReadApi {
  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
      };

  static dynamic _unwrap(http.Response r) {
    final body = jsonDecode(r.body);
    if (r.statusCode >= 400 || body['success'] != true) {
      throw Exception(body['message'] ?? 'HTTP ${r.statusCode}');
    }
    return body['data'];
  }

  // Sementara, sampai halaman Login dari tim jadi
  static Future<void> devLogin() async {
    final r = await http.post(
      Uri.parse('${ApiConfig.base}/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': 'aji@wetpad.test', 'password': 'password'}),
    );
    Session.token = _unwrap(r)['token'];
  }

  static Future<Story> getStory(int id) async {
    if (SciFiStoryContent.stories.containsKey(id)) {
      return Story.fromJson(SciFiStoryContent.stories[id]!);
    }
    try {
      final r = await http
          .get(Uri.parse('${ApiConfig.base}/stories/$id'), headers: _headers)
          .timeout(const Duration(seconds: 2));
      return Story.fromJson(_unwrap(r));
    } catch (_) {
      return Story.fromJson(SciFiStoryContent.stories.values.first);
    }
  }

  static Future<List<PartItem>> getParts(int storyId) async {
    if (SciFiStoryContent.partsList.containsKey(storyId)) {
      return SciFiStoryContent.partsList[storyId]!
          .map((e) => PartItem.fromJson(e))
          .toList();
    }
    try {
      final r = await http
          .get(Uri.parse('${ApiConfig.base}/stories/$storyId/parts'),
              headers: _headers)
          .timeout(const Duration(seconds: 2));
      return (_unwrap(r) as List).map((e) => PartItem.fromJson(e)).toList();
    } catch (_) {
      return SciFiStoryContent.partsList[1]!
          .map((e) => PartItem.fromJson(e))
          .toList();
    }
  }

  static Future<Part> getPart(int id) async {
    if (SciFiStoryContent.partContents.containsKey(id)) {
      return Part.fromJson(SciFiStoryContent.partContents[id]!);
    }
    try {
      final r = await http
          .get(Uri.parse('${ApiConfig.base}/parts/$id'), headers: _headers)
          .timeout(const Duration(seconds: 2));
      return Part.fromJson(_unwrap(r));
    } catch (_) {
      return Part.fromJson(SciFiStoryContent.partContents.values.first);
    }
  }

  /// return {voted: bool, votes: int}
  static Future<Map<String, dynamic>> toggleVote(int partId) async {
    try {
      final r = await http
          .post(Uri.parse('${ApiConfig.base}/parts/$partId/vote'),
              headers: _headers)
          .timeout(const Duration(seconds: 2));
      return Map<String, dynamic>.from(_unwrap(r));
    } catch (_) {
      return {'voted': true, 'votes': 65001};
    }
  }

  static Future<List<StoryMini>> getRecommendations(int storyId) async {
    try {
      final r = await http
          .get(Uri.parse('${ApiConfig.base}/stories/$storyId/recommendations'),
              headers: _headers)
          .timeout(const Duration(seconds: 2));
      return (_unwrap(r) as List).map((e) => StoryMini.fromJson(e)).toList();
    } catch (_) {
      final otherStories = SciFiStoryContent.stories.values
          .where((s) => s['id'] != storyId)
          .map((s) => StoryMini.fromJson({
                'id': s['id'],
                'title': s['title'],
                'cover_url': s['cover_url'],
                'description': s['description'],
                'status': s['status'],
                'parts_count': s['parts_count'],
              }))
          .toList();
      return otherStories;
    }
  }

  static Future<void> reportStory(int storyId, String reason, String detail) async {
    if (Session.token == null) throw Exception('Login dulu');
    final r = await http.post(
      Uri.parse('${ApiConfig.base}/stories/$storyId/reports'),
      headers: _headers,
      body: jsonEncode({'reason': reason, 'detail': detail}),
    );
    _unwrap(r);
  }

  static Future<void> addToLibrary(int storyId) async {
    if (Session.token == null) throw Exception('Login dulu');
    final r = await http.post(
      Uri.parse('${ApiConfig.base}/library'),
      headers: _headers,
      body: jsonEncode({'story_id': storyId}),
    );
    _unwrap(r);
  }

  static Future<void> saveProgress(int storyId, int partId) async {
    if (Session.token == null) return;
    try {
      await http.put(
        Uri.parse('${ApiConfig.base}/library/$storyId/progress'),
        headers: _headers,
        body: jsonEncode({'last_part_id': partId}),
      );
    } catch (_) {}
  }

  static Future<List<Comment>> getComments(int partId, {int? paragraph}) async {
    final q = paragraph != null ? '?paragraph=$paragraph' : '';
    final r = await http.get(
        Uri.parse('${ApiConfig.base}/parts/$partId/comments$q'),
        headers: _headers);
    return (_unwrap(r) as List).map((e) => Comment.fromJson(e)).toList();
  }

  static Future<List<Comment>> getReplies(int commentId) async {
    final r = await http.get(Uri.parse('${ApiConfig.base}/comments/$commentId/replies'),
        headers: _headers);
    return (_unwrap(r) as List).map((e) => Comment.fromJson(e)).toList();
  }

  static Future<Comment> addComment(int partId, String body,
      {int? parentId, int? paragraph}) async {
    if (Session.token == null) throw Exception('Login dulu');
    final r = await http.post(
      Uri.parse('${ApiConfig.base}/parts/$partId/comments'),
      headers: _headers,
      body: jsonEncode({
        'body': body,
        if (parentId != null) 'parent_id': parentId,
        if (paragraph != null) 'paragraph_index': paragraph,
      }),
    );
    return Comment.fromJson(_unwrap(r));
  }

  static Future<List<Reaction>> getReactions(int partId, int idx) async {
    final r = await http.get(
        Uri.parse('${ApiConfig.base}/parts/$partId/paragraphs/$idx/reactions'),
        headers: _headers);
    return (_unwrap(r) as List).map((e) => Reaction.fromJson(e)).toList();
  }

  static Future<List<Reaction>> react(int partId, int idx, int sticker) async {
    if (Session.token == null) throw Exception('Login dulu');
    final r = await http.post(
      Uri.parse('${ApiConfig.base}/parts/$partId/paragraphs/$idx/reactions'),
      headers: _headers,
      body: jsonEncode({'sticker': sticker}),
    );
    return (_unwrap(r) as List).map((e) => Reaction.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> toggleLike(int commentId) async {
    final r = await http.post(Uri.parse('${ApiConfig.base}/comments/$commentId/like'),
        headers: _headers);
    return Map<String, dynamic>.from(_unwrap(r));
  }
}