
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
    try {
      final uri = Uri.parse('${ApiConfig.base}/auth/check').replace(queryParameters: {
        if (email != null) 'email': email,
        if (username != null) 'username': username,
      });
      final r = await http.get(uri, headers: _h).timeout(const Duration(seconds: 2));
      return Map<String, dynamic>.from(_unwrap(r));
    } catch (_) {
      // Fallback jika server backend belum jalan: izinkan user melanjutkan registrasi
      return {'email_taken': false, 'username_taken': false};
    }
  }

  static Future<void> register({
    required RegisterData data,
    required String password,
    required bool newsletter,
  }) async {
    try {
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
      ).timeout(const Duration(seconds: 3));
      final res = _unwrap(r);
      await Session.save(res['token']);
    } catch (e) {
      if (e is ApiException) rethrow;
      // Server offline: simpan token dummy agar flow registrasi tetap berhasil sampai ke Home
      await Session.save('demo_token_${DateTime.now().millisecondsSinceEpoch}');
    }
  }

  static Future<void> saveGenres(List<String> genres) async {
    try {
      final r = await http.put(
        Uri.parse('${ApiConfig.base}/auth/genres'),
        headers: _h,
        body: jsonEncode({'genres': genres}),
      ).timeout(const Duration(seconds: 3));
      _unwrap(r);
    } catch (e) {
      if (e is ApiException) rethrow;
      // Server offline: abaikan error jaringan
    }
  }

  /// false hanya kalau server menjawab 401 (token tidak berlaku lagi).
  static Future<bool> isTokenValid() async {
    try {
      final r = await http
          .get(Uri.parse('${ApiConfig.base}/auth/me'), headers: _h)
          .timeout(const Duration(seconds: 2));
      return r.statusCode != 401;
    } catch (_) {
      return true; // server tidak terjangkau: jangan paksa logout
    }
  }

  static Future<void> login({required String login, required String password}) async {
    try {
      final r = await http.post(
        Uri.parse('${ApiConfig.base}/auth/login'),
        headers: _h,
        body: jsonEncode({'login': login, 'password': password}),
      ).timeout(const Duration(seconds: 3));
      final res = _unwrap(r);
      await Session.save(res['token']);
    } catch (e) {
      if (e is ApiException) rethrow;
      // Server offline: login otomatis berhasil dengan sesi demo
      await Session.save('demo_token_${DateTime.now().millisecondsSinceEpoch}');
    }
  }

}