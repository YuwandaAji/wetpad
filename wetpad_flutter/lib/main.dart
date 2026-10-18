import 'package:flutter/material.dart';
import 'core/config_api.dart';
import 'core/theme.dart';
import 'auth/pages/splash_page.dart';
import 'library/screens/library_data.dart';
import 'library/screens/library_screen.dart';
import 'library/widgets/app_bottom_nav.dart';
import 'readmode/pages/story_pager.dart';
import 'search/data/mock_search_repository.dart';
import 'search/data/search_models.dart';
import 'search/screens/search_screen.dart';

final _searchRepo = MockSearchRepository();
final _libraryRepo = MockLibraryRepository();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wetpad',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const SplashPage(),
      routes: {
        '/search': (_) => const _TabPage(index: 1),
        '/library': (_) => const _TabPage(index: 2),
      },
    );
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage({required this.index});

  final int index;

  void _openStory(BuildContext context, SearchStory s) {
    final id = int.tryParse(s.id);
    if (id == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => StoryPager(storyIds: [id], initialIndex: 0),
    ));
  }

  void _onTap(BuildContext context, int i) {
    if (i == index) return;
    if (i == 1) Navigator.of(context).pushReplacementNamed('/search');
    if (i == 2) Navigator.of(context).pushReplacementNamed('/library');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: index == 1
          ? SearchScreen(
              repository: _searchRepo,
              onStoryTap: (s) => _openStory(context, s),
            )
          : LibraryScreen(repository: _libraryRepo),
      bottomNavigationBar: AppBottomNav(
        currentIndex: index,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}
