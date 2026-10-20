
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config_api.dart';
import 'search_models.dart';
import 'search_repository.dart';

class ApiSearchRepository implements SearchRepository {
  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
      };

  Future<dynamic> _get(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('${ApiConfig.base}$path').replace(queryParameters: query);
    final r = await http.get(uri, headers: _headers);
    final body = jsonDecode(r.body);
    if (r.statusCode >= 400 || body['success'] != true) {
      throw Exception(body['message'] ?? 'HTTP ${r.statusCode}');
    }
    return body['data'];
  }

  @override
  Future<List<SearchCategory>> fetchCategories() async {
    final d = await _get('/search/categories') as List;
    return d
        .map((e) => SearchCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<CategoryFeed> fetchCategoryFeed(
    String categoryId, {
    StoryFilter filter = const StoryFilter(),
  }) async {
    final d = await _get('/search/feed', {
      'category': categoryId,
      'sort': filter.sort == StorySort.newest ? 'new' : 'hot',
      if (filter.tags.isNotEmpty) 'tags': filter.tags.join(','),
    });
    return CategoryFeed.fromJson(Map<String, dynamic>.from(d));
  }

  @override
  Future<List<String>> fetchFilterTags(String categoryId) async {
    final d = await _get('/search/tags', {'category': categoryId}) as List;
    return d.map((e) => e.toString()).toList();
  }

  @override
  Future<List<String>> fetchTrendingKeywords() async {
    final d = await _get('/search/trending') as List;
    return d.map((e) => e.toString()).toList();
  }

  @override
  Future<List<SearchStory>> searchStories(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final d = await _get('/search', {'q': q}) as List;
    return d
        .map((e) => SearchStory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}