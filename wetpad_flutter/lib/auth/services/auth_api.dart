
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config_api.dart';

class ApiException implements Exception {
  final String message;
  final Map<String, String> fields;
  ApiException(this.message, [this.fields = const {}]);

  @override
  String toString() => message;
}

class RegisterData {
  final String email, username, birthDate; // birthDate: YYYY-MM-DD
  final String? pronoun;
  const RegisterData({
    required this.email,
    required this.username,
    required this.birthDate,
    this.pronoun,
  });
}

class AuthApi {
  static Map<String, String> get _h => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
      };

  static dynamic _unwrap(http.Response r) {
    final body = jsonDecode(r.body);
    if (r.statusCode >= 400 || body['success'] != true) {
      final errs = <String, String>{};
      if (body['errors'] is Map) {
        (body['errors'] as Map).forEach((k, v) {
          errs['$k'] = (v is List && v.isNotEmpty) ? '${v.first}' : '$v';
        });
      }
      throw ApiException(body['message']?.toString() ?? 'HTTP ${r.statusCode}', errs);
    }
    return body['data'];
  }

  static Future<Map<String, dynamic>> check({String? email, String? username}) async {
    final uri = Uri.parse('${ApiConfig.base}/auth/check').replace(queryParameters: {
      if (email != null) 'email': email,
      if (username != null) 'username': username,
    });
    final r = await http.get(uri, headers: _h);
    return Map<String, dynamic>.from(_unwrap(r));
  }

  static Future<void> register({
    required RegisterData data,
    required String password,
    required bool newsletter,
  }) async {
    final r = await http.post(
      Uri.parse('${ApiConfig.base}/auth/register'),
      headers: _h,
      body: jsonEncode({
        'email': data.email,
        'username': data.username,
        'password': password,
        'birth_date': data.birthDate,
        'pronoun': data.pronoun,
        'newsletter': newsletter,
        'terms': true,
      }),
    );
    final res = _unwrap(r);
    await Session.save(res['token']);
  }

  static Future<void> saveGenres(List<String> genres) async {
    final r = await http.put(
      Uri.parse('${ApiConfig.base}/auth/genres'),
      headers: _h,
      body: jsonEncode({'genres': genres}),
    );
    _unwrap(r);
  }

  /// false hanya kalau server menjawab 401 (token tidak berlaku lagi).
  static Future<bool> isTokenValid() async {
    try {
      final r = await http
          .get(Uri.parse('${ApiConfig.base}/auth/me'), headers: _h)
          .timeout(const Duration(seconds: 5));
      return r.statusCode != 401;
    } catch (_) {
      return true; // server tidak terjangkau: jangan paksa logout
    }
  }

  static Future<void> login({required String login, required String password}) async {
    final r = await http.post(
      Uri.parse('${ApiConfig.base}/auth/login'),
      headers: _h,
      body: jsonEncode({'login': login, 'password': password}),
    );
    final res = _unwrap(r);
    await Session.save(res['token']);
  }

}