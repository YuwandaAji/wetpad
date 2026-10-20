import 'package:flutter/material.dart';
import '../models/novel.dart';
import 'novel_cover_image.dart';

/// Section Daftar Novel Populer & Terbaru (List Novel)
class NovelListSection extends StatelessWidget {
  final List<Novel> novels;
  final ValueChanged<Novel> onNovelTap;
  final String title;
  final String subtitle;

  const NovelListSection({
    super.key,
    required this.novels,
    required this.onNovelTap,
    this.title = "Daftar Novel Sains & Distopia",
    this.subtitle = "Peringkat cerita paling diminati minggu ini",
  });

  @override
  Widget build(BuildContext context) {
    if (novels.isEmpty) return const SizedBox.shrink();

    // Warna teks ikut tema aktif (terang/gelap)
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5B00),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Semua",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List Novel Items
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: novels.length,
          separatorBuilder: (context, index) => const Divider(
            height: 24,
            thickness: 0.8,
            color: Color(0xFFEEEEEE),
          ),
          itemBuilder: (context, index) {
            final novel = novels[index];
            return _buildNovelListItem(context, novel, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildNovelListItem(BuildContext context, Novel novel, int rank) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onNovelTap(novel),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Peringkat (Rank Badge #1, #2, #3, ...)
            Container(
              width: 26,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "#$rank",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: rank <= 3 ? const Color(0xFFFF5B00) : const Color(0xFF9E9E9E),
                ),
              ),
            ),

            // Cover Novel
            NovelCoverImage(
              novel: novel,
              width: 78,
              height: 114,
              borderRadius: BorderRadius.circular(6),
            ),

            const SizedBox(width: 14),

            // Informasi Novel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    novel.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Penulis
                  Text(
                    "Oleh ${novel.author}",
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Sinopsis Singkat
                  Text(
                    novel.synopsis,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Stats dan Tags
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        size: 13,
                        color: Color(0xFF757575),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        novel.reads,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        novel.votes,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${novel.parts} Bagian",
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      // Tag status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: novel.isCompleted
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          novel.isCompleted ? "Tamat" : "Berlanjut",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: novel.isCompleted
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFEF6C00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
