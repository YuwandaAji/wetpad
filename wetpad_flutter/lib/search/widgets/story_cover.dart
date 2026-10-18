import 'package:flutter/material.dart';

import 'search_style.dart';

class StoryCover extends StatelessWidget {
  const StoryCover({
    super.key,
    required this.cover,
    required this.title,
    required this.width,
    required this.height,
    this.radius = 6,
    this.showOriginalBadge = false,
  });

  final String cover;
  final String title;
  final double width;
  final double height;
  final double radius;
  final bool showOriginalBadge;

  Widget _placeholder() {
    final hue = (title.hashCode.abs() % 360).toDouble();
    final top = HSLColor.fromAHSL(1, hue, 0.35, 0.28).toColor();
    final bottom = HSLColor.fromAHSL(1, hue, 0.35, 0.12).toColor();
    return Container(
      padding: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'serif',
        ),
      ),
    );
  }

  Widget _image() {
    if (cover.isEmpty) return _placeholder();
    if (cover.startsWith('http')) {
      return Image.network(
        cover,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return Image.asset(
      cover,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _image(),
            if (showOriginalBadge)
              const Positioned(top: 0, left: 0, child: _OriginalBadge()),
          ],
        ),
      ),
    );
  }
}

class _OriginalBadge extends StatelessWidget {
  const _OriginalBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.only(left: 5, top: 2),
      alignment: Alignment.topLeft,
      decoration: const BoxDecoration(
        color: SearchColors.accent,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
      ),
      child: const Text(
        'W',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
