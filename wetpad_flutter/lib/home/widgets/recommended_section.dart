import 'package:flutter/material.dart';
import '../models/novel.dart';
import 'novel_cover_image.dart';

/// Section Rekomendasi Novel Sains & Distopia
class RecommendedSection extends StatelessWidget {
  final List<Novel> novels;
  final ValueChanged<Novel> onNovelTap;

  const RecommendedSection({
    super.key,
    required this.novels,
    required this.onNovelTap,
  });

  @override
  Widget build(BuildContext context) {
    if (novels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rekomendasi Cerita Sains & Distopia",
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1C),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Koleksi terpilih dunia fiksi ilmiah, kecerdasan buatan, dan masa depan kelam",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 235,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: novels.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final novel = novels[index];
              return _buildNovelCard(context, novel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNovelCard(BuildContext context, Novel novel) {
    return InkWell(
      onTap: () => onNovelTap(novel),
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 115,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Novel
            NovelCoverImage(
              novel: novel,
              width: 115,
              height: 165,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 6),

            // Judul Novel
            Text(
              novel.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1C),
                height: 1.15,
              ),
            ),

            const SizedBox(height: 3),

            // Statistik (Reads & Votes)
            Row(
              children: [
                const Icon(
                  Icons.remove_red_eye_outlined,
                  size: 12,
                  color: Color(0xFF757575),
                ),
                const SizedBox(width: 3),
                Text(
                  novel.reads,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.star_rounded,
                  size: 13,
                  color: Color(0xFFFF9800),
                ),
                const SizedBox(width: 2),
                Text(
                  novel.votes,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
