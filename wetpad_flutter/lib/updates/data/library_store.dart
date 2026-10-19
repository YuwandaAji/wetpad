import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../models/story.dart';

class LibraryStore extends ChangeNotifier {
  LibraryStore._();

  static final LibraryStore instance = LibraryStore._();

  final Map<String, Story> _privateLibrary = {};
  final Map<String, List<Story>> _readingLists = {};

  bool isInPrivateLibrary(Story story) => _privateLibrary.containsKey(story.id);

  bool isInReadingList(String title, Story story) =>
      (_readingLists[title] ?? const []).any(
        (existing) => existing.id == story.id,
      );

  List<ProfileReadingList> readingListsFor(Profile profile) {
    final lists = <ProfileReadingList>[];
    final knownTitles = <String>{};

    for (final readingList in profile.readingLists) {
      knownTitles.add(readingList.title);
      final addedStories = _readingLists[readingList.title] ?? const [];
      final storiesById = <String, Story>{
        for (final story in readingList.stories) story.id: story,
        for (final story in addedStories) story.id: story,
      };
      lists.add(
        ProfileReadingList(
          title: readingList.title,
          stories: storiesById.values.toList(),
        ),
      );
    }

    for (final entry in _readingLists.entries) {
      if (knownTitles.contains(entry.key)) continue;
      lists.add(
        ProfileReadingList(title: entry.key, stories: entry.value.toList()),
      );
    }

    if (profile.isMe && _privateLibrary.isNotEmpty) {
      final privateStories = _privateLibrary.values.toList();
      if (privateStories.isNotEmpty) {
        lists.insert(
          0,
          ProfileReadingList(
            title: 'Perpustakaan (Pribadi)',
            stories: privateStories,
          ),
        );
      }
    }
    return lists;
  }

  void addToPrivateLibrary(Story story) {
    if (_privateLibrary.containsKey(story.id)) return;
    _privateLibrary[story.id] = story;
    notifyListeners();
  }

  void addToReadingList(String title, Story story) {
    final stories = _readingLists.putIfAbsent(title, () => []);
    if (stories.any((existing) => existing.id == story.id)) return;
    stories.add(story);
    notifyListeners();
  }

  void createReadingList(String title, Story story) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Cannot be empty.');
    }
    addToReadingList(normalizedTitle, story);
  }
}
