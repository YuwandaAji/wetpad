import 'package:flutter/material.dart';

import 'app/main_shell.dart';
import 'auth/pages/splash_page.dart';
import 'core/config_api.dart';
import 'core/theme.dart';
import 'write/pages/add_story_info_page.dart';

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
        '/home': (_) => const MainShell(initialIndex: 0),
        '/search': (_) => const MainShell(initialIndex: 1),
        '/library': (_) => const MainShell(initialIndex: 2),
        '/write': (_) => const MainShell(initialIndex: 3),
        '/add-story': (_) => const AddStoryInfoPage(),
      },
    );
  }
}
