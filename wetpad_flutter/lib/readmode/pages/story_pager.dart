
import 'package:flutter/material.dart';
import 'story_detail_page.dart';

class StoryPager extends StatefulWidget {
  final List<int> storyIds;
  final int initialIndex;
  const StoryPager({super.key, required this.storyIds, this.initialIndex = 0});

  @override
  State<StoryPager> createState() => _StoryPagerState();
}

class _StoryPagerState extends State<StoryPager> {
  late final PageController _c = PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageView.builder(
        controller: _c,
        itemCount: widget.storyIds.length,
        itemBuilder: (_, i) => StoryDetailPage(
          storyId: widget.storyIds[i],
          pagerCount: widget.storyIds.length,
          pagerIndex: i,
        ),
      );
}