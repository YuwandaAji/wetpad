
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config_api.dart';
import '../models/novel.dart';

String _count(int n) {
  String f(double v, String unit) {
    final s = v
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '')
        .replaceAll('.', ',');
    return '$s $unit';
  }

  if (n >= 1000000) return f(n / 1000000, 'Jt');
  if (n >= 1000) return f(n / 1000, 'Rb');
  return '$n';
}

Novel _novel(Map<String, dynamic> j) => Novel(
      id: j['id'],
      title: j['title'],
      author: j['author'] ?? '-',
      synopsis: j['description'] ?? '',
      coverUrl: j['cover_url'] ?? '',
      tags: List<String>.from(j['tags'] ?? []),
      reads: _count(j['reads_total'] ?? 0),
      votes: _count(j['votes_total'] ?? 0),
      parts: j['parts_count'] ?? 0,
      isCompleted: j['status'] == 'completed',
    );

List<Novel> _novels(dynamic list) =>
    (list as List).map((e) => _novel(Map<String, dynamic>.from(e))).toList();

class HomeSection {
  final String key, title;
  final List<Novel> stories;
  HomeSection(this.key, this.title, this.stories);
}

class HomeData {
  final List<Novel> topPicks, recommended;
  final List<HomeSection> sections;
  HomeData(this.topPicks, this.recommended, this.sections);
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
    final d = body['data'];
    return HomeData(
      _novels(d['top_picks']),
      _novels(d['recommended']),
      [
        for (final s in (d['sections'] as List))
          HomeSection(s['key'], s['title'], _novels(s['stories'])),
      ],
    );
  }
}