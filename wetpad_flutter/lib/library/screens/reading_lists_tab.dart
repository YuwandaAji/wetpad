import 'package:flutter/material.dart';

import '../widgets/reading_list_tile.dart';
import 'library_data.dart';

/// Tab "READING LISTS".
class ReadingListsTab extends StatelessWidget {
  const ReadingListsTab({
    super.key,
    required this.lists,
    required this.storiesOf,
    required this.onOpen,
    required this.onMenu,
    required this.onLikedTap,
  });

  final List<LibraryReadingList> lists;
  final List<LibraryStory> Function(LibraryReadingList) storiesOf;
  final void Function(LibraryReadingList) onOpen;
  final void Function(LibraryReadingList, ReadingListMenuAction) onMenu;
  final VoidCallback onLikedTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        LikedListsTile(count: 0, onTap: onLikedTap),
        const SizedBox(height: 30),
        for (final l in lists) ...[
          ReadingListTile(
            list: l,
            stories: storiesOf(l),
            onTap: () => onOpen(l),
            onMenuSelected: (a) => onMenu(l, a),
          ),
          const SizedBox(height: 26),
        ],
      ],
    );
  }
}
