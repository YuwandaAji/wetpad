import 'package:flutter/material.dart';

import 'library_style.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav(
      {super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LibColors.background,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: InkResponse(
                    onTap: () => onTap(i),
                    radius: 30,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _icon(i, i == currentIndex),
                        const SizedBox(height: 5),
                        Container(
                          width: 24,
                          height: 3,
                          decoration: BoxDecoration(
                            color: i == currentIndex
                                ? LibColors.orange
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(int i, bool selected) {
    final color = selected ? LibColors.orange : const Color(0xFFB0B0B0);
    switch (i) {
      case 0:
        return Icon(Icons.home_outlined, size: 30, color: color);
      case 1:
        return Icon(Icons.search_rounded, size: 30, color: color);
      case 2:
        return CustomPaint(
            size: const Size(30, 30), painter: _LibraryIconPainter(color));
      case 3:
        return Icon(Icons.edit_outlined, size: 28, color: color);
      default:
        return Icon(Icons.notifications_none_rounded, size: 30, color: color);
    }
  }
}

/// Ikon Library Wattpad: " /|| "
class _LibraryIconPainter extends CustomPainter {
  _LibraryIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s.width * 0.12, s.height * 0.92),
        Offset(s.width * 0.36, s.height * 0.08), p);
    canvas.drawLine(Offset(s.width * 0.55, s.height * 0.08),
        Offset(s.width * 0.55, s.height * 0.92), p);
    canvas.drawLine(Offset(s.width * 0.82, s.height * 0.08),
        Offset(s.width * 0.82, s.height * 0.92), p);
  }

  @override
  bool shouldRepaint(_LibraryIconPainter old) => old.color != color;
}
