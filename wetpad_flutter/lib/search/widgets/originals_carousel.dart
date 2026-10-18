import 'package:flutter/material.dart';

import '../data/search_models.dart';
import 'search_style.dart';
import 'story_cover.dart';

class OriginalsCarousel extends StatelessWidget {
  const OriginalsCarousel({
    super.key,
    required this.title,
    required this.stories,
    required this.onTap,
  });

  final String title;
  final List<SearchStory> stories;
  final void Function(SearchStory) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
          child: Text(title, style: SearchText.sectionTitle),
        ),
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = stories[i];
              return GestureDetector(
                onTap: () => onTap(s),
                child: StoryCover(
                  cover: s.cover,
                  title: s.title,
                  width: 80,
                  height: 122,
                  radius: 6,
                  showOriginalBadge: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
