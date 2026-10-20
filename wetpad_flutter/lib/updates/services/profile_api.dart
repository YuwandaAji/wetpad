import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config_api.dart';
import '../data/follow_store.dart';
import '../data/profiles_data.dart';
import '../models/post.dart';
import '../models/profile.dart';

class ProfileApi {
  static Map<String, String> get _h => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
      };

  static dynamic _unwrap(http.Response r) {
    final body = jsonDecode(r.body);
    if (r.statusCode >= 400 || (body is Map && body['success'] == false)) {
      throw Exception(body is Map ? (body['message'] ?? 'HTTP ${r.statusCode}') : 'HTTP ${r.statusCode}');
    }
    return body is Map ? body['data'] : body;
  }

  static Uri _u(String path) => Uri.parse('${ApiConfig.base}$path');
  static String _name(Profile p) => Uri.encodeComponent(p.username);

  /// GET /users/{username}
  static Future<Profile> fetch(String username) async {
    final r = await http
        .get(_u('/users/${Uri.encodeComponent(username)}'), headers: _h)
        .timeout(const Duration(seconds: 10));
    final j = Map<String, dynamic>.from(_unwrap(r));
    final p = Profile.fromJson(j);
    FollowStore.instance.setFollowing(p.id, j['is_following'] == true);
    return p;
  }

  /// Load the logged-in user's profile and store it in ProfilesData.me
  static Future<Profile> loadMe() async {
    final r = await http.get(_u('/auth/me'), headers: _h).timeout(const Duration(seconds: 10));
    final username = _unwrap(r)['username'] as String;
    final p = await fetch(username);
    ProfilesData.me = p;
    return p;
  }

  static Future<void> setFollow(Profile p, bool follow) async {
    final req = follow
        ? http.post(_u('/users/${_name(p)}/follow'), headers: _h)
        : http.delete(_u('/users/${_name(p)}/follow'), headers: _h);
    _unwrap(await req.timeout(const Duration(seconds: 10)));
  }

  static Future<void> saveAbout(String about) async {
    final r = await http
        .put(_u('/auth/profile'), headers: _h, body: jsonEncode({'about': about}))
        .timeout(const Duration(seconds: 10));
    _unwrap(r);
  }

  static Future<List<Post>> posts(Profile p) async {
    final r = await http.get(_u('/users/${_name(p)}/posts'), headers: _h)
        .timeout(const Duration(seconds: 10));
    return [
      for (final j in (_unwrap(r) as List)) Post.fromJson(Map<String, dynamic>.from(j)),
    ];
  }

  static Future<void> createPost(Profile p, String text, {String? parentId}) async {
    final r = await http
        .post(_u('/users/${_name(p)}/posts'),
            headers: _h,
            body: jsonEncode({'body': text, if (parentId != null) 'parent_id': int.parse(parentId)}))
        .timeout(const Duration(seconds: 10));
    _unwrap(r);
  }

  static Future<void> deletePost(String id) async {
    final r = await http.delete(_u('/posts/$id'), headers: _h).timeout(const Duration(seconds: 10));
    _unwrap(r);
  }
}