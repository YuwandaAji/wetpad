import 'package:flutter/material.dart';

import '../data/search_models.dart';
import 'search_style.dart';
import 'story_cover.dart';

/// Satu baris story: cover, (rank) judul, author, views, parts, tags.
/// [rank] null = tanpa nomor (dipakai di hasil pencarian).
class RankedStoryTile extends StatelessWidget {
  const RankedStoryTile({
    super.key,
    required this.story,
    required this.onTap,
    this.rank,
  });

  final SearchStory story;
  final int? rank;
  final VoidCallback onTap;

  static const _maxTags = 3;

  @override
  Widget build(BuildContext context) {
    final extra = story.tags.length - _maxTags;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StoryCover(
              cover: story.cover,
              title: story.title,
              width: 72,
              height: 108,
              radius: 5,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (rank != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text('$rank', style: SearchText.rank),
                        ),
                      Expanded(
                        child: Text(story.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SearchText.storyTitle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(story.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SearchText.author),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.visibility_outlined,
                          color: SearchColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(formatCount(story.views), style: SearchText.stat),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 7),
                        child: Icon(Icons.circle,
                            color: SearchColors.border, size: 4),
                      ),
                      const Icon(Icons.format_list_bulleted,
                          color: SearchColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text('${story.parts}', style: SearchText.stat),
                    ],
                  ),
                  if (story.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final t in story.tags.take(_maxTags))
                          Container(
                            constraints: const BoxConstraints(maxWidth: 90),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: SearchColors.surface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(t,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: SearchText.tag),
                          ),
                        if (extra > 0)
                          const Text('+ more', style: SearchText.tag),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
