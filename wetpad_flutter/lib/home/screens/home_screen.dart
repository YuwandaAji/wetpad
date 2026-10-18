import 'package:flutter/material.dart';

import '../../readmode/pages/story_detail_page.dart';
import '../data/sci_fi_novel_data.dart';
import '../models/novel.dart';
import '../widgets/home_header.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/novel_list_section.dart';
import '../widgets/recommended_section.dart';
import '../widgets/top_picks_collage.dart';

/// Halaman Utama (Home Screen) Wetpad
/// Berisi Top Picks (kolase), Rekomendasi Novel Sains & Distopia, dan List Novel
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentNavIndex = 0;

  void _onNovelTap(Novel novel) {
    // Navigasi ke halaman detail novel (readmode)
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StoryDetailPage(storyId: novel.id)),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == _currentNavIndex) {
      if (index == 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    setState(() {
      _currentNavIndex = index;
    });

    if (index == 1) {
      Navigator.of(context).pushNamed('/search').then((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
      });
    } else if (index == 2) {
      Navigator.of(context).pushNamed('/library').then((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
      });
    } else if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tulis Cerita Baru: Buka imajinasi sci-fi Anda!"),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() => _currentNavIndex = 0);
    } else if (index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Belum ada notifikasi baru"),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() => _currentNavIndex = 0);
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Menggunakan tema bersih (light) khusus halaman Home persis seperti di foto
      data: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5B00),
          primary: const Color(0xFFFF5B00),
          surface: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const HomeHeader(),
        body: RefreshIndicator(
          color: const Color(0xFFFF5B00),
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 1. Top Picks Collage ("Cerita pilihan untuk kamu")
                TopPicksCollage(
                  novels: SciFiNovelData.topPicks,
                  onNovelTap: _onNovelTap,
                ),

                // 2. Recommended Novels ("Rekomendasi Cerita Sains & Distopia")
                RecommendedSection(
                  novels: SciFiNovelData.recommendedNovels,
                  onNovelTap: _onNovelTap,
                ),

                // 3. List Novel ("Daftar Novel Sains & Distopia")
                NovelListSection(
                  novels: SciFiNovelData.novelList,
                  onNovelTap: _onNovelTap,
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
        bottomNavigationBar: HomeBottomNav(
          currentIndex: _currentNavIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }
}
