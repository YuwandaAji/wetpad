import 'package:flutter/material.dart';

import 'search_style.dart';

/// Daftar keyword yang lagi hype.
class TrendingList extends StatelessWidget {
  const TrendingList({super.key, required this.keywords, required this.onTap});

  final List<String> keywords;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Text('TRENDING', style: SearchText.caps),
        const SizedBox(height: 4),
        for (final k in keywords)
          InkWell(
            onTap: () => onTap(k),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                children: [
                  const Icon(Icons.trending_up,
                      color: SearchColors.teal, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text(k, style: SearchText.trending)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
