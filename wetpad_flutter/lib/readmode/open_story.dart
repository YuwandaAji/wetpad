
import 'package:flutter/material.dart';
import 'pages/story_detail_page.dart';
import 'pages/story_pager.dart';

/// Dari daftar di Home: bisa digeser antar novel, urut sesuai daftar yang diketuk.
void openStoryFromList(BuildContext context, List<int> ids, int index) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => StoryPager(storyIds: ids, initialIndex: index),
  ));
}

/// Dari Search: satu novel, tanpa titik geser.
void openStoryFromSearch(BuildContext context, int id) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => StoryDetailPage(storyId: id),
  ));
}