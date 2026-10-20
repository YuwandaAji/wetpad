import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../updates/data/profile_store.dart'; // sesuaikan kalau path temanya beda


class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onPremiumTap;
  final VoidCallback? onGiftTap;
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    this.onPremiumTap,
    this.onGiftTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Latar ikut tema aktif (terang/gelap)
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Wattpad Logo "W"
            _buildWattpadLogo(),

            const Spacer(),

            // Tombol "Coba Premium"
            InkWell(
              onTap:
                  onPremiumTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Fitur Wetpad Premium - Akses Tanpa Batas",
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.premiumBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 18,
                      color: AppColors.lavender,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Coba Premium",
                      style: TextStyle(
                        color: AppColors.lavender,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Tombol Gift Box (Kado Hadiah Koin / Hadiah Harian)
            InkWell(
              onTap:
                  onGiftTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Klaim Koin Harian Anda!"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC107),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  size: 18,
                  color: Color(0xFF212121),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Avatar profil user, ikut ProfileStore
            AnimatedBuilder(
              animation: ProfileStore.instance,
              builder: (context, _) {
                final s = ProfileStore.instance;
                final img = s.avatarImage;
                final initial = s.name.trim().isEmpty
                    ? '?'
                    : s.name.trim()[0].toUpperCase();
                return InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFF38A3C8),
                    backgroundImage: img,
                    child: img == null
                        ? Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Logo Wattpad oranye berbentuk huruf 'W' khas Wattpad
  Widget _buildWattpadLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(size: const Size(36, 36), painter: _WattpadLogoPainter()),
      ],
    );
  }
}

/// Custom painter untuk menggambar ikon W Wattpad yang presisi
class _WattpadLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.orange
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Stroke 1 (Kiri)
    path.moveTo(w * 0.12, h * 0.28);
    path.cubicTo(w * 0.05, h * 0.40, w * 0.15, h * 0.85, w * 0.32, h * 0.88);
    path.cubicTo(w * 0.45, h * 0.90, w * 0.48, h * 0.60, w * 0.40, h * 0.42);
    path.cubicTo(w * 0.35, h * 0.28, w * 0.20, h * 0.18, w * 0.12, h * 0.28);

    // Stroke 2 (Kanan / Sambungan W)
    path.moveTo(w * 0.40, h * 0.42);
    path.cubicTo(w * 0.50, h * 0.70, w * 0.62, h * 0.90, w * 0.78, h * 0.82);
    path.cubicTo(w * 0.95, h * 0.72, w * 0.98, h * 0.35, w * 0.82, h * 0.24);
    path.cubicTo(w * 0.68, h * 0.15, w * 0.55, h * 0.32, w * 0.58, h * 0.50);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
