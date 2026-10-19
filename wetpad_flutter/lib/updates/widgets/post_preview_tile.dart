import 'package:flutter/material.dart';

import '../models/post_preview.dart';
import '../theme/app_theme.dart';

class PostPreviewTile extends StatelessWidget {
  final PostPreview post;
  const PostPreviewTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
        fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.link);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${post.text}…',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('LIHAT LEBIH LANJUT', style: linkStyle),
              Text('${post.commentCount} komentar', style: linkStyle),
            ],
          ),
        ],
      ),
    );
  }
}
