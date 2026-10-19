import 'package:flutter/material.dart';

import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'story_cover.dart';

/// Compact card: 75x113 cover, 12dp gap, info on the right.
class StoryHorizontalCard extends StatelessWidget {
  final Story story;
  final double width;

  const StoryHorizontalCard({super.key, required this.story, this.width = 265});

  @override
  Widget build(BuildContext context) {
    final shownTags = story.tags.take(3).toList();
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoryCover(story: story),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(story.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(story.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye_outlined,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(compactNumber(story.reads),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('•',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    const Icon(Icons.format_list_bulleted,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text('${story.parts}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final t in shownTags) _TagChip(label: t),
                    if (story.tags.length > shownTags.length)
                      const Text('+ selanjutnya',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textPrimary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 34),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
    );
  }
}
