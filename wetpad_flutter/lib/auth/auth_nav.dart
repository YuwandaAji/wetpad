import 'package:flutter/material.dart';

import '../readmode/pages/story_detail_page.dart';
import '../shell/main_shell.dart';

void goHome(BuildContext context) {
  // TODO: ganti dengan halaman utama (bottom nav) dari tim
 Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const StoryDetailPage(storyId: 1)),
    (_) => false,
  );
}
