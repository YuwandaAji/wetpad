import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WattpadBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const WattpadBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _icons = <IconData>[
    Icons.home_outlined,
    Icons.search,
    Icons.library_books_outlined,
    Icons.edit_outlined,
    Icons.notifications_none,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(_icons.length, (i) {
              final selected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icons[i],
                          size: 26,
                          color:
                              selected ? AppColors.orange : AppColors.textSecondary),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: 3,
                        color: selected ? AppColors.orange : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
