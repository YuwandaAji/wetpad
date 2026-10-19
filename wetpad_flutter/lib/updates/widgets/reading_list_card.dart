import 'package:flutter/material.dart';

import '../models/reading_list.dart';
import '../theme/app_theme.dart';
import 'community_avatar.dart';
import 'story_cover.dart';

/// Collage: one big cover + two small stacked covers, tight 4dp gaps.
class ReadingListCard extends StatelessWidget {
  final ReadingList list;
  const ReadingListCard({super.key, required this.list});

  static const double _bigW = 73, _bigH = 112, _smallW = 36, _smallH = 54, _gap = 4;
  static const double width = _bigW + _gap + _smallW;

  @override
  Widget build(BuildContext context) {
    final s = list.stories;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoryCover(story: s[0], width: _bigW, height: _bigH),
              const SizedBox(width: _gap),
              Column(
                children: [
                  StoryCover(story: s[1], width: _smallW, height: _smallH),
                  const SizedBox(height: _gap),
                  StoryCover(story: s[2], width: _smallW, height: _smallH),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(list.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Row(
            children: [
              CommunityAvatar(community: list.owner, size: 18),
              const SizedBox(width: 5),
              Expanded(
                child: Text(list.owner.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
