import 'package:flutter/material.dart';
import '../models/novel.dart';
import 'novel_cover_image.dart';

/// Komponen "Cerita pilihan untuk kamu" persis seperti layout di Wattpad
class TopPicksCollage extends StatelessWidget {
  final List<Novel> novels;
  final ValueChanged<Novel> onNovelTap;

  const TopPicksCollage({
    super.key,
    required this.novels,
    required this.onNovelTap,
  });

  @override
  Widget build(BuildContext context) {
    if (novels.isEmpty) return const SizedBox.shrink();

    // Novel pertama untuk cover besar (kiri)
    final mainNovel = novels.first;
    // 4 novel berikutnya untuk 2 kolom kecil bertumpuk (tengah & kanan)
    final subNovels = novels.skip(1).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul Bagian: "Cerita pilihan untuk kamu"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Cerita pilihan untuk kamu",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              // Warna teks ikut tema aktif (terang/gelap)
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Scroll Horizontal untuk Pack Kolase
        SizedBox(
          height: 260,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              // Kolase Paket 1 (Cover Utama + 4 Cover Mini)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Cover Utama Besar di Kiri
                  GestureDetector(
                    onTap: () => onNovelTap(mainNovel),
                    child: Hero(
                      tag: 'novel_cover_${mainNovel.id}',
                      child: NovelCoverImage(
                        novel: mainNovel,
                        width: 165,
                        height: 260,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 2. Kolom Pertama dari 2 cover bertumpuk
                  if (subNovels.isNotEmpty)
                    SizedBox(
                      width: 90,
                      height: 260,
                      child: Column(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => onNovelTap(subNovels[0]),
                              child: NovelCoverImage(
                                novel: subNovels[0],
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (subNovels.length > 1)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => onNovelTap(subNovels[1]),
                                child: NovelCoverImage(
                                  novel: subNovels[1],
                                  width: double.infinity,
                                  height: double.infinity,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 8),

                  // 3. Kolom Kedua dari 2 cover bertumpuk
                  if (subNovels.length > 2)
                    SizedBox(
                      width: 90,
                      height: 260,
                      child: Column(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => onNovelTap(subNovels[2]),
                              child: NovelCoverImage(
                                novel: subNovels[2],
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (subNovels.length > 3)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => onNovelTap(subNovels[3]),
                                child: NovelCoverImage(
                                  novel: subNovels[3],
                                  width: double.infinity,
                                  height: double.infinity,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 8),

                  // 4. Intipan (peek) cover berikutnya seperti di screenshot asli
                  if (novels.length > 5)
                    GestureDetector(
                      onTap: () => onNovelTap(novels[5]),
                      child: NovelCoverImage(
                        novel: novels[5],
                        width: 75,
                        height: 260,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
