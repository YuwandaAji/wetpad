import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/auth_nav.dart';
import '../data/profile_store.dart';

/// Dialog edit deskripsi (dipanggil saat teks "Ketuk di sini…" diketuk).
Future<void> showEditBioDialog(BuildContext context) async {
  final store = ProfileStore.instance;
  final c = TextEditingController(text: store.about);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Tentang kamu'),
      content: TextField(
        controller: c,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        maxLength: 500,
        decoration: const InputDecoration(
          hintText: 'Tulis deskripsi tentang diri kamu…',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
  if (ok == true) await store.update(about: c.text);
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _store = ProfileStore.instance;
  late final _name = TextEditingController(text: _store.name);
  late final _username = TextEditingController(text: _store.username);
  late final _about = TextEditingController(text: _store.about);

  Uint8List? _newAvatar;
  bool _removeAvatar = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _about.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() {
      _newAvatar = bytes;
      _removeAvatar = false;
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final user = _username.text.trim().replaceFirst('@', '');
    if (name.isEmpty) {
      setState(() => _error = 'Nama tidak boleh kosong');
      return;
    }
    if (!RegExp(r'^[A-Za-z0-9_]{3,20}$').hasMatch(user)) {
      setState(() => _error = 'Username 3–20 karakter: huruf, angka, atau _');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    await _store.update(
      name: name,
      username: user,
      about: _about.text,
      avatar: _newAvatar,
      removeAvatar: _removeAvatar,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
  }

  Future<void> _copyLink() async {
    final link =
        'https://www.wattpad.com/user/${Uri.encodeComponent(_store.username)}';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tautan profil disalin. Bagikan kepada temanmu!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? img = _newAvatar != null
        ? MemoryImage(_newAvatar!)
        : (_removeAvatar ? null : _store.avatarImage);
    final initial = _name.text.trim().isEmpty
        ? '?'
        : _name.text.trim()[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        actions: [
          TextButton(onPressed: _save, child: const Text('SIMPAN')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pick,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFF14171C),
                    backgroundImage: img,
                    child: img == null
                        ? Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6122),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: _pick, child: const Text('Ganti foto')),
              if (img != null)
                TextButton(
                  onPressed: () => setState(() {
                    _newAvatar = null;
                    _removeAvatar = true;
                  }),
                  child: const Text('Hapus foto'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _username,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixText: '@',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _about,
            minLines: 3,
            maxLines: 6,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Tentang',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.link),
            title: const Text('Salin tautan profil'),
            onTap: _copyLink,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}