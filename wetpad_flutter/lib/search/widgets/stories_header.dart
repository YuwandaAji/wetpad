import 'package:flutter/material.dart';

import '../data/search_models.dart';
import 'search_style.dart';

/// Baris "1.28K Stories" + tombol Filter.
/// [filterActive] true -> ikon Filter berwarna oranye.
class StoriesHeader extends StatelessWidget {
  const StoriesHeader({
    super.key,
    required this.total,
    required this.onFilter,
    this.filterActive = false,
  });

  final int total;
  final VoidCallback onFilter;
  final bool filterActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text('${formatCount(total)} Stories',
                style: SearchText.sectionTitle),
          ),
          Material(
            color: SearchColors.surface,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: onFilter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune,
                        color:
                            filterActive ? SearchColors.accent : Colors.white,
                        size: 18),
                    const SizedBox(width: 6),
                    const Text('Filter', style: SearchText.button),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
