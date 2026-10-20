import 'package:flutter/material.dart';

import '../home/screens/home_screen.dart';
import '../home/widgets/home_bottom_nav.dart';
import '../library/screens/api_library_repository.dart';
import '../library/screens/library_screen.dart';
import '../library/widgets/app_bottom_nav.dart';
import '../readmode/open_story.dart';
import '../search/data/api_search_repository.dart';
import '../search/data/search_models.dart';
import '../search/screens/search_screen.dart';
import '../write/pages/write_page.dart';

final _searchRepo = ApiSearchRepository();
final _libraryRepo = ApiLibraryRepository();

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _i = widget.initialIndex;
  int _libraryKey = 0; // naik tiap Library dibuka -> data dimuat ulang

  void _openSearchStory(SearchStory s) {
    final id = int.tryParse(s.id);
    if (id == null) return;
    openStoryFromSearch(context, id); // dari Search: tanpa titik geser
  }

  void _go(int i) {
    if (i == _i) return;
    setState(() {
      if (i == 2) _libraryKey++;
      _i = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      SearchScreen(repository: _searchRepo, onStoryTap: _openSearchStory),
      LibraryScreen(key: ValueKey(_libraryKey), repository: _libraryRepo),
      const WritePage(),
      const _ComingSoon('Pembaruan'),
    ];

    return PopScope(
      canPop: _i == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _i = 0);
      },
      child: Scaffold(
        body: IndexedStack(index: _i, children: pages),
        bottomNavigationBar: _i == 0
            ? HomeBottomNav(currentIndex: _i, onTap: _go)
            : AppBottomNav(currentIndex: _i, onTap: _go),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String name;
  const _ComingSoon(this.name);

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF121212),
    child: Center(
      child: Text(
        'Halaman $name segera hadir',
        style: const TextStyle(fontSize: 18, color: Color(0xFFA0A0A0)),
      ),
    ),
  );
}