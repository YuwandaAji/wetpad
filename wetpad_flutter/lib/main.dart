import 'package:flutter/material.dart';
import 'readmode/pages/story_detail_page.dart';
import 'readmode/pages/story_pager.dart';
import 'readmode/services/read_api.dart';
import 'core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await ReadApi.devLogin(); // hapus kalau Login sudah jadi
  } catch (_) {}
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
    home: const StoryPager(storyIds: [1, 2, 3], initialIndex: 0),
  );
  }
}