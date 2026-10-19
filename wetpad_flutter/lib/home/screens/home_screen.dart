import 'package:flutter/material.dart';

import '../../readmode/open_story.dart';
import '../models/novel.dart';
import '../services/home_api.dart';
import '../widgets/home_header.dart';
import '../widgets/novel_list_section.dart';
import '../widgets/recommended_section.dart';
import '../widgets/top_picks_collage.dart';

/// Halaman Utama (Home) Wetpad. Data dari backend: GET /api/home
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _orange = Color(0xFFFF5B00);

  final ScrollController _scrollController = ScrollController();
  HomeData? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final d = await HomeApi.fetch();
      if (!mounted) return;
      setState(() {
        _data = d;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (_data != null) {
        // muat ulang gagal: data lama tetap ditampilkan
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat ulang: $msg')));
      } else {
        setState(() {
          _error = msg;
          _loading = false;
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }

  /// Buka halaman cerita. Daftar yang diketuk dikirim lengkap, supaya
  /// bisa digeser ke novel lain sesuai urutan daftar itu.
  void _open(Novel n, List<Novel> list) {
    final ids = list.map((x) => x.id).toList();
    final i = ids.indexOf(n.id);
    openStoryFromList(context, ids, i < 0 ? 0 : i);
  }

  Widget _centered(Widget child) => SizedBox(height: 420, child: Center(child: child));

  Widget _errorView() => _centered(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 56, color: Color(0xFF9E9E9E)),
            const SizedBox(height: 12),
            const Text('Tidak bisa memuat Beranda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _orange),
              onPressed: _retry,
              child: const Text('Coba lagi'),
            ),
          ]),
        ),
      );

  Widget _content(HomeData d) {
    if (d.topPicks.isEmpty && d.recommended.isEmpty && d.sections.isEmpty) {
      return _centered(const Text('Belum ada cerita.',
          style: TextStyle(fontSize: 16, color: Color(0xFF757575))));
    }

    final sections = d.sections;
    final ranked = sections.isEmpty ? <Novel>[] : sections.first.stories.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // 1. Cerita pilihan untuk kamu
        TopPicksCollage(
          novels: d.topPicks,
          onNovelTap: (n) => _open(n, d.topPicks),
        ),

        // 2. Rekomendasi (sesuai genre pilihan pengguna)
        RecommendedSection(
          title: 'Rekomendasi untuk kamu',
          subtitle: 'Berdasarkan genre bacaan favoritmu',
          novels: d.recommended,
          onNovelTap: (n) => _open(n, d.recommended),
        ),

        // 3. Daftar peringkat genre teratas
        if (sections.isNotEmpty)
          NovelListSection(
            title: 'Daftar Novel ${sections.first.title}',
            subtitle: 'Peringkat cerita paling diminati minggu ini',
            novels: ranked,
            onNovelTap: (n) => _open(n, ranked),
          ),

        // 4. Genre lainnya
        for (final s in sections.skip(1))
          RecommendedSection(
            title: 'Populer di ${s.title}',
            subtitle: 'Cerita ${s.title} yang paling banyak dibaca',
            novels: s.stories,
            onNovelTap: (n) => _open(n, s.stories),
          ),

        const SizedBox(height: 36),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Tema terang khusus halaman Home
      data: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _orange,
          primary: _orange,
          surface: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const HomeHeader(),
        body: RefreshIndicator(
          color: _orange,
          onRefresh: _load,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: _loading
                ? _centered(const CircularProgressIndicator(color: _orange))
                : (_data == null ? _errorView() : _content(_data!)),
          ),
        ),
      ),
    );
  }
}