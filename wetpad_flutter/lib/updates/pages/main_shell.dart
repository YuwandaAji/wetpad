import 'package:flutter/material.dart';

import '../widgets/wattpad_bottom_nav.dart';
import 'updates_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 4; // open on "Updates" like the screenshots

  static const _placeholderLabels = ['Beranda', 'Cari', 'Perpustakaan', 'Tulis'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (final label in _placeholderLabels)
            Center(child: Text(label, style: const TextStyle(fontSize: 20))),
          const UpdatesPage(),
        ],
      ),
      bottomNavigationBar: WattpadBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
