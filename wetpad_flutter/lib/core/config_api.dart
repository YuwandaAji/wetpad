
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const base = 'http://127.0.0.1:8000/api';
}

class Session {
  static String? token;
  static const _key = 'wetpad_token';

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString(_key);
  }

  static Future<void> save(String t) async {
    token = t;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, t);
  }

  static Future<void> clear() async {
    token = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}