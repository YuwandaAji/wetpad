import 'package:flutter/material.dart';

import '../library/screens/library_data.dart';
import '../library/screens/library_screen.dart';
import '../library/widgets/app_bottom_nav.dart';
import '../library/widgets/library_style.dart';
import '../readmode/pages/story_pager.dart';
import '../search/data/mock_search_repository.dart';
import '../search/data/search_models.dart';
import '../search/screens/search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 1;

  final _searchRepo = MockSearchRepository();
  final _libraryRepo = MockLibraryRepository();

  void _openStory(SearchStory s) {
    final id = int.tryParse(s.id);
    if (id == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('ID story tidak valid')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryPager(storyIds: [id], initialIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const names = ['Home', 'Search', '', 'Write', 'Notifications'];
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < 5; i++)
            if (i == 1)
              SearchScreen(repository: _searchRepo, onStoryTap: _openStory)
            else if (i == 2)
              LibraryScreen(repository: _libraryRepo)
            else
              Center(
                child: Text(
                  names[i],
                  style: const TextStyle(color: LibColors.textSecondary),
                ),
              ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
