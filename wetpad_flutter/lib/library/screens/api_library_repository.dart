
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config_api.dart';
import 'library_data.dart';

class ApiLibraryRepository implements LibraryRepository {
  Map<String, String> get _h => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
      };

  Uri _u(String path) => Uri.parse('${ApiConfig.base}$path');

  dynamic _unwrap(http.Response r) {
    final body = jsonDecode(r.body);
    if (r.statusCode >= 400 || body['success'] != true) {
      throw Exception(body['message'] ?? 'HTTP ${r.statusCode}');
    }
    return body['data'];
  }

  @override
  Future<List<LibraryStory>> fetchStories() async {
    final r = await http.get(_u('/library'), headers: _h);
    return (_unwrap(r) as List)
        .map((e) => LibraryStory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> saveStory(LibraryStory s) async {
    final r = await http.put(
      _u('/library/${s.id}'),
      headers: _h,
      body: jsonEncode({
        'is_archived': s.isArchived,
        'is_offline': s.isOffline,
        'last_read_at': s.lastReadAt.toUtc().toIso8601String(),
      }),
    );
    _unwrap(r);
  }

  @override
  Future<void> deleteStory(String id) async {
    final r = await http.delete(_u('/library/$id'), headers: _h);
    _unwrap(r);
  }

  @override
  Future<List<LibraryReadingList>> fetchReadingLists() async {
    final r = await http.get(_u('/reading-lists'), headers: _h);
    return (_unwrap(r) as List)
        .map((e) => LibraryReadingList.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> saveReadingList(LibraryReadingList l) async {
    final r = await http.put(
      _u('/reading-lists/${Uri.encodeComponent(l.id)}'),
      headers: _h,
      body: jsonEncode({
        'name': l.name,
        'story_ids': l.storyIds.map(int.tryParse).whereType<int>().toList(),
        'is_public': l.isPublic,
      }),
    );
    _unwrap(r);
  }

  @override
  Future<void> deleteReadingList(String id) async {
    final r = await http.delete(_u('/reading-lists/${Uri.encodeComponent(id)}'), headers: _h);
    _unwrap(r);
  }
}