import 'package:flutter/material.dart';

import '../../readmode/open_story.dart';
import '../../core/theme.dart'; // sesuaikan kalau path temanya beda
import '../models/novel.dart';
import '../services/home_api.dart';
import '../widgets/home_header.dart';
import '../widgets/novel_list_section.dart';
import '../widgets/recommended_section.dart';
import '../widgets/top_picks_collage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _open(Novel n, List<Novel> list) {
    final ids = list.map((x) => x.id).toList();
    final i = ids.indexOf(n.id);
    openStoryFromList(context, ids, i < 0 ? 0 : i);
  }

  Widget _centered(Widget child) =>
      SizedBox(height: 420, child: Center(child: child));

  Widget _errorView() {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return _centered(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: muted),
            const SizedBox(height: 12),
            const Text(
              'Tidak bisa memuat Beranda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: muted),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
              onPressed: _retry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(HomeData d) {
    if (d.topPicks.isEmpty && d.recommended.isEmpty && d.sections.isEmpty) {
      return _centered(
        Text(
          'Belum ada cerita.',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final sections = d.sections;
    final ranked = sections.isEmpty
        ? <Novel>[]
        : sections.first.stories.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

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

    return Scaffold(
      appBar: const HomeHeader(),
      body: RefreshIndicator(
        color: AppColors.orange,
        onRefresh: _load,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: _loading
              ? _centered(
                  const CircularProgressIndicator(color: AppColors.orange),
                )
              : (_data == null ? _errorView() : _content(_data!)),
        ),
      ),
    );
  }
}
