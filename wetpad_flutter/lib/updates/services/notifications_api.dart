import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config_api.dart';
import '../models/notification_item.dart';

class NotificationsApi {
  static Map<String, String> get _h => {
        'Accept': 'application/json',
        if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
      };

  static dynamic _unwrap(http.Response r) {
    if (r.statusCode == 401) {
      throw Exception('Sesi habis, silakan masuk lagi.');
    }
    dynamic body;
    try {
      body = jsonDecode(r.body);
    } on FormatException {
      throw Exception(
        'Respons server tidak valid (HTTP ${r.statusCode}). '
        'Cek log Laravel di storage/logs/laravel.log.',
      );
    }
    if (r.statusCode >= 400 || body['success'] != true) {
      throw Exception(body['message'] ?? 'HTTP ${r.statusCode}');
    }
    return body['data'];
  }

  /// GET /api/notifications -> daftar notifikasi milik user yang login
  static Future<List<NotificationItem>> fetch() async {
    if (Session.token == null) {
      throw Exception('Masuk dulu untuk melihat notifikasi.');
    }
    try {
      final r = await http
          .get(Uri.parse('${ApiConfig.base}/notifications'), headers: _h)
          .timeout(const Duration(seconds: 8));
      final d = _unwrap(r);
      return [
        for (final j in (d['items'] as List))
          NotificationItem.fromJson(Map<String, dynamic>.from(j)),
      ];
    } on TimeoutException {
      throw Exception(
        'Server tidak merespons. Pastikan "php artisan serve" berjalan '
        'dan alamat API (${ApiConfig.base}) bisa dijangkau dari perangkat ini.',
      );
    } on http.ClientException {
      throw Exception(
        'Tidak bisa terhubung ke server (${ApiConfig.base}). '
        'Emulator Android memakai 10.0.2.2, bukan 127.0.0.1.',
      );
    }
  }

  /// PUT /api/notifications/{id}/read -> tandai sudah dibaca
  static Future<void> markRead(String id) async {
    try {
      await http
          .put(Uri.parse('${ApiConfig.base}/notifications/$id/read'), headers: _h)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // gagal menandai dibaca tidak perlu mengganggu pengguna
    }
  }
}