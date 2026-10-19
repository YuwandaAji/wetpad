
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config_api.dart';

class HomeStory {
  final int id, partsCount, readsTotal, votesTotal;
  final String title, status;
  final String? coverUrl, description, genre, author;
  final List<String> tags;

  HomeStory.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        title = j['title'],
        coverUrl = j['cover_url'],
        description = j['description'],
        genre = j['genre'],
        status = j['status'] ?? 'ongoing',
        author = j['author'],
        tags = List<String>.from(j['tags'] ?? []),
        partsCount = j['parts_count'] ?? 0,
        readsTotal = j['reads_total'] ?? 0,
        votesTotal = j['votes_total'] ?? 0;
}

class HomeSection {
  final String key, title;
  final List<HomeStory> stories;

  HomeSection.fromJson(Map<String, dynamic> j)
      : key = j['key'],
        title = j['title'],
        stories = (j['stories'] as List).map((e) => HomeStory.fromJson(e)).toList();
}

class HomeData {
  final List<HomeStory> topPicks, recommended;
  final List<HomeSection> sections;

  HomeData.fromJson(Map<String, dynamic> j)
      : topPicks = (j['top_picks'] as List).map((e) => HomeStory.fromJson(e)).toList(),
        recommended = (j['recommended'] as List).map((e) => HomeStory.fromJson(e)).toList(),
        sections = (j['sections'] as List).map((e) => HomeSection.fromJson(e)).toList();
}

class HomeApi {
  static Future<HomeData> fetch() async {
    final r = await http.get(
      Uri.parse('${ApiConfig.base}/home'),
      headers: {
        'Accept': 'application/json',
        if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
      },
    );
    final body = jsonDecode(r.body);
    if (r.statusCode >= 400 || body['success'] != true) {
      throw Exception(body['message'] ?? 'HTTP ${r.statusCode}');
    }
    return HomeData.fromJson(body['data']);
  }
}