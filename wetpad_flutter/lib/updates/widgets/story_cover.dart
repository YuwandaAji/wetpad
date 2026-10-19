import 'package:flutter/material.dart';

import '../models/story.dart';

class StoryCover extends StatelessWidget {
  final Story story;
  final double width;
  final double height;

  const StoryCover({
    super.key,
    required this.story,
    this.width = 75,
    this.height = 113,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(width * 0.07),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: story.coverColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        story.coverText,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: (width * 0.14).clamp(4.5, 14.0),
          height: 1.15,
        ),
      ),
    );
  }
}
