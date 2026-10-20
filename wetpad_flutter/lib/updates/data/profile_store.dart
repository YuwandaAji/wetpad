import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State profil akun kita sendiri. Disimpan permanen di shared_preferences.
class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._().._load();

  static const _kName = 'profile_name';
  static const _kUser = 'profile_username';
  static const _kAbout = 'profile_about';
  static const _kCoins = 'profile_coins';
  static const _kAvatar = 'profile_avatar_b64';

  String name = 'Ali Mukahfi';
  String username = 'sencroma';
  String about = '';
  int coins = 0;

  Uint8List? _avatarBytes;
  ImageProvider? avatarImage; // di-cache supaya tidak berkedip saat rebuild

  void _setBytes(Uint8List? b) {
    _avatarBytes = b;
    avatarImage = b == null ? null : MemoryImage(b);
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    name = p.getString(_kName) ?? name;
    username = p.getString(_kUser) ?? username;
    about = p.getString(_kAbout) ?? about;
    coins = p.getInt(_kCoins) ?? coins;
    final b64 = p.getString(_kAvatar);
    if (b64 != null) _setBytes(base64Decode(b64));
    notifyListeners();
  }

  Future<void> update({
    String? name,
    String? username,
    String? about,
    Uint8List? avatar,
    bool removeAvatar = false,
  }) async {
    if (name != null) this.name = name.trim();
    if (username != null) this.username = username.trim();
    if (about != null) this.about = about.trim();
    if (removeAvatar) {
      _setBytes(null);
    } else if (avatar != null) {
      _setBytes(avatar);
    }
    notifyListeners();

    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, this.name);
    await p.setString(_kUser, this.username);
    await p.setString(_kAbout, this.about);
    await p.setInt(_kCoins, coins);
    if (_avatarBytes == null) {
      await p.remove(_kAvatar);
    } else {
      await p.setString(_kAvatar, base64Encode(_avatarBytes!));
    }
  }
}