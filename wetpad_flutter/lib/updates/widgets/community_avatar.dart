import 'package:flutter/material.dart';

import '../models/community.dart';

class CommunityAvatar extends StatelessWidget {
  final Community community;
  final double size;

  /// Shows the community name as a small logo (thin lines above/below),
  /// like the "Temukan komunitasmu" section.
  final bool wordmark;

  const CommunityAvatar({
    super.key,
    required this.community,
    this.size = 30,
    this.wordmark = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = wordmark
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: size * 0.36, height: 1, color: community.textColor),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    community.name.toLowerCase(),
                    style: TextStyle(
                      color: community.textColor,
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Container(width: size * 0.36, height: 1, color: community.textColor),
              ],
            ),
          )
        : Text(
            community.initial,
            style: TextStyle(
              color: community.textColor,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.45,
            ),
          );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: community.color, shape: BoxShape.circle),
      child: child,
    );
  }
}
