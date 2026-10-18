import 'package:flutter/material.dart';

/// Bottom Navigation Bar persis seperti di tampilan Wattpad
class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: InkResponse(
                    onTap: () => onTap(i),
                    radius: 28,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildNavIcon(i, i == currentIndex),
                        const SizedBox(height: 4),
                        // Garis indikator oranye di bawah ikon aktif
                        Container(
                          width: 24,
                          height: 3,
                          decoration: BoxDecoration(
                            color: i == currentIndex
                                ? const Color(0xFFFF5B00)
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

  Widget _buildNavIcon(int index, bool isSelected) {
    final color = isSelected ? const Color(0xFFFF5B00) : const Color(0xFF616161);

    switch (index) {
      case 0:
        // Beranda (Home)
        return Icon(
          isSelected ? Icons.home_rounded : Icons.home_outlined,
          size: 28,
          color: color,
        );
      case 1:
        // Pencarian (Search)
        return Icon(
          Icons.search_rounded,
          size: 28,
          color: color,
        );
      case 2:
        // Perpustakaan / Rak Buku (\ ||)
        return SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(
            painter: _BookshelfPainter(color: color),
          ),
        );
      case 3:
        // Tulis / Pensil
        return Icon(
          Icons.edit_outlined,
          size: 26,
          color: color,
        );
      case 4:
        // Notifikasi / Lonceng
        return Icon(
          Icons.notifications_none_rounded,
          size: 28,
          color: color,
        );
      default:
        return Icon(Icons.circle, size: 24, color: color);
    }
  }
}

/// Custom painter untuk ikon rak buku (\ ||) khas Wattpad
class _BookshelfPainter extends CustomPainter {
  final Color color;
  _BookshelfPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Buku miring pertama (\)
    canvas.drawLine(
      Offset(w * 0.22, h * 0.25),
      Offset(w * 0.40, h * 0.78),
      paint,
    );

    // Buku tegak kedua (|)
    canvas.drawLine(
      Offset(w * 0.55, h * 0.22),
      Offset(w * 0.55, h * 0.78),
      paint,
    );

    // Buku tegak ketiga (|)
    canvas.drawLine(
      Offset(w * 0.72, h * 0.22),
      Offset(w * 0.72, h * 0.78),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BookshelfPainter oldDelegate) =>
      oldDelegate.color != color;
}
