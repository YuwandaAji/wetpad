import 'package:flutter/material.dart';

import '../models/profile.dart';

class ProfileAvatar extends StatelessWidget {
  final Profile profile;
  final double size;
  final bool ring; // lingkaran tepi gelap seperti di header

  const ProfileAvatar({
    super.key,
    required this.profile,
    this.size = 40,
    this.ring = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCommunity = profile.type == ProfileType.community;

    final Widget child = isCommunity && size >= 60
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: size * 0.36, height: 1.5, color: profile.textColor),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    profile.name.toLowerCase(),
                    style: TextStyle(
                      color: profile.textColor,
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(width: size * 0.36, height: 1.5, color: profile.textColor),
              ],
            ),
          )
        : Text(
            profile.name.isEmpty ? '?' : profile.name[0].toUpperCase(),
            style: TextStyle(
              color: profile.textColor,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.45,
            ),
          );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: profile.color,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: const Color(0xFF222222), width: 3) : null,
      ),
      child: child,
    );
  }
}