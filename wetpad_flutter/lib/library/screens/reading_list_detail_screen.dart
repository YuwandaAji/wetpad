import 'package:flutter/material.dart';

import '../widgets/library_style.dart';
import '../widgets/story_item.dart';
import 'library_data.dart';

/// Isi sebuah reading list (grid story).
class ReadingListDetailScreen extends StatelessWidget {
  const ReadingListDetailScreen({
    super.key,
    required this.title,
    required this.stories,
    required this.onStoryTap,
  });

  final String title;
  final List<LibraryStory> stories;
  final void Function(LibraryStory) onStoryTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: stories.isEmpty
          ? const Center(
              child: Text('This reading list is empty.',
                  style: TextStyle(color: LibColors.textSecondary)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                StoryCollection(
                  stories: stories,
                  viewMode: LibraryViewMode.grid,
                  showProgress: false,
                  onTap: onStoryTap,
                ),
              ],
            ),
    );
  }
}
