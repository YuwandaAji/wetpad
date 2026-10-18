import 'package:flutter/material.dart';

/// Cover story. Pakai [coverUrl] bila ada; kalau tidak ada / gagal dimuat,
/// dibuat cover placeholder gelap berisi judul & penulis.
class StoryCover extends StatelessWidget {
  const StoryCover({
    super.key,
    required this.title,
    this.author,
    this.coverUrl,
    this.borderRadius = 3,
  });

  final String title;
  final String? author;
  final String? coverUrl;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final fallback = _GeneratedCover(title: title, author: author);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: coverUrl == null
          ? fallback
          : Image.network(
              coverUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => fallback,
              loadingBuilder: (_, child, p) => p == null ? child : fallback,
            ),
    );
  }
}

class _GeneratedCover extends StatelessWidget {
  const _GeneratedCover({required this.title, this.author});
  final String title;
  final String? author;

  @override
  Widget build(BuildContext context) {
    final hue = (title.hashCode.abs() % 360).toDouble();
    final top = HSLColor.fromAHSL(1, hue, 0.30, 0.10).toColor();
    final bottom = HSLColor.fromAHSL(1, hue, 0.40, 0.22).toColor();
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth.isFinite ? c.maxWidth : 80.0;
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(w * 0.08),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, bottom]),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: (w * 0.13).clamp(7, 22).toDouble(),
                    height: 1.1,
                  ),
                ),
              ),
            ),
            if (author != null)
              Text(
                author!.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: (w * 0.09).clamp(6, 14).toDouble(),
                ),
              ),
          ],
        ),
      );
    });
  }
}
