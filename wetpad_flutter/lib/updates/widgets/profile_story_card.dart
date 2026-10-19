import 'package:flutter/material.dart';

import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'story_cover.dart';

/// Kartu cerita ala profil: cover, judul, statistik, deskripsi, peringkat.
class ProfileStoryCard extends StatelessWidget {
  final Story story;
  final double width;

  const ProfileStoryCard({super.key, required this.story, this.width = 290});

  @override
  Widget build(BuildContext context) {
    const grey = TextStyle(fontSize: 14, color: AppColors.textSecondary);
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoryCover(story: story, width: 97, height: 151),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 2,
                  children: [
                    _StoryMetric(
                      icon: Icons.remove_red_eye_outlined,
                      value: idCompact(story.reads),
                      style: grey,
                    ),
                    _StoryMetric(
                      icon: Icons.star_border,
                      value: idCompact(story.stars),
                      style: grey,
                    ),
                    _StoryMetric(
                      icon: Icons.format_list_bulleted,
                      value: '${story.parts}',
                      style: grey,
                    ),
                  ],
                ),
                if (story.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    story.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: grey,
                  ),
                ],
                if (story.rankLabel != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.military_tech_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          story.rankLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final TextStyle style;

  const _StoryMetric({
    required this.icon,
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(value, style: style),
      ],
    );
  }
}
