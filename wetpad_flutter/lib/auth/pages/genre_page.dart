
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../auth_nav.dart';
import '../services/auth_api.dart';
import '../widgets/auth_widgets.dart';

const kGenres = [
  'Romansa', 'Fiksi Remaja', 'Fiksi Penggemar', 'Fantasi', 'Acak',
  'Cerita Pendek', 'Fiksi Umum', 'ChickLit', 'Humor', 'Aksi',
  'Misteri', 'Thriller', 'Spiritual', 'Fiksi Sejarah', 'Nonfiksi',
  'Fiksi Ilmiah', 'Petualangan', 'Horor', 'Vampir', 'Manusia Serigala',
  'Paranormal', 'Puisi', 'Klasik',
];

class GenrePage extends StatefulWidget {
  const GenrePage({super.key});

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  final List<String> _picked = [];
  bool _loading = false;

  void _toggle(String g) {
    setState(() {
      if (_picked.contains(g)) {
        _picked.remove(g);
      } else if (_picked.length >= 3) {
        authSnack(context, 'Pilih maksimal 3 genre.');
      } else {
        _picked.add(g);
      }
    });
  }

  Future<void> _next() async {
    if (_loading || _picked.isEmpty) return;
    setState(() => _loading = true);
    try {
      await AuthApi.saveGenres(_picked);
      if (mounted) goHome(context);
    } catch (e) {
      if (mounted) authSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _chip(String g) {
    final on = _picked.contains(g);
    return GestureDetector(
      onTap: () => _toggle(g),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
        decoration: BoxDecoration(
          color: on ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(g,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: on ? AppColors.bg : Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Column(children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 56, 24, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Apa 3 genre bacaan favoritmu?',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, height: 1.2)),
            SizedBox(height: 14),
            Text('Pilih minimal 1 genre untuk memulai dengan rekomendasi yang dipersonalisasi.',
                style: TextStyle(fontSize: 19, height: 1.4)),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Wrap(spacing: 14, runSpacing: 14, children: kGenres.map(_chip).toList()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: PillButton('Lanjutkan',
              loading: _loading, onPressed: _picked.isEmpty ? null : _next),
        ),
      ]),
    );
  }
}