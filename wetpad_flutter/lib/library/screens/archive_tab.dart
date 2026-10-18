import 'package:flutter/material.dart';

import '../widgets/library_style.dart';
import '../widgets/story_item.dart';
import 'library_data.dart';

// Tab "ARCHIVE"//
class ArchiveTab extends StatelessWidget {
  const ArchiveTab({
    super.key,
    required this.stories,
    required this.onStoryMenu,
  });
  final List<LibraryStory> stories;
  final void Function(LibraryStory) onStoryMenu;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        if (stories.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Text(
                'No archived stories.',
                style: TextStyle(color: LibColors.textSecondary, fontSize: 16),
              ),
            ),
          )
        else
          StoryCollection(
            stories: stories,
            viewMode: LibraryViewMode.grid,
            showProgress: false,
            spacing: 22,
            onTap: onStoryMenu,
            onLongPress: onStoryMenu,
          ),
      ],
    );
  }
}
