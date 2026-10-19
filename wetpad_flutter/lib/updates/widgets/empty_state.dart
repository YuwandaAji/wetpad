import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showIllustration;
  final bool boldTitle;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.showIllustration = false,
    this.boldTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIllustration) ...[
              const _Illustration(),
              const SizedBox(height: 32),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: boldTitle ? 20 : 17,
                height: 1.3,
                fontWeight: boldTitle ? FontWeight.w800 : FontWeight.w400,
                color: boldTitle ? AppColors.textPrimary : Colors.grey.shade700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: boldTitle ? AppColors.textPrimary : Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple flat illustration built from widgets (sun, hill, icon).
class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 170,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 10,
            right: 50,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD60A),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            child: Container(
              width: 70,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFBD3DA),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Container(
            width: 240,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7A33),
              borderRadius: BorderRadius.vertical(
                top: Radius.elliptical(120, 40),
              ),
            ),
          ),
          const Positioned(
            bottom: 28,
            child: Icon(Icons.pedal_bike, size: 84, color: Color(0xFF6A4A3C)),
          ),
        ],
      ),
    );
  }
}

/// Grey skeleton card shown on the empty Social Feed.
class FeedEmptyIllustration extends StatelessWidget {
  const FeedEmptyIllustration({super.key});

  static const _c = Color(0xFFE6E6E6);

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: _c,
          borderRadius: BorderRadius.circular(h / 2),
        ),
      );

  Widget _block(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: _c,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 206,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 8,
                backgroundColor: Color(0xFFD0D0D0),
                child: Text('w',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 6),
              Expanded(child: _bar(double.infinity, 5)),
              const SizedBox(width: 22),
              _bar(13, 5),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _block(38, 60),
              const SizedBox(width: 4),
              Column(
                children: [
                  _block(17, 28),
                  const SizedBox(height: 4),
                  _block(17, 28),
                ],
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    _bar(double.infinity, 5),
                    const SizedBox(height: 4),
                    _bar(double.infinity, 5),
                    const SizedBox(height: 4),
                    _bar(55, 5),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}