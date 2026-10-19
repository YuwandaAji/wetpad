import 'package:flutter/material.dart';

import '../models/community.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'community_avatar.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final VoidCallback onOpenProfile;

  const CommunityCard({
    super.key,
    required this.community,
    required this.isFollowing,
    required this.onToggleFollow,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpenProfile,
            child: Column(
              children: [
                CommunityAvatar(community: community, size: 46, wordmark: true),
                const SizedBox(height: 10),
                Text(
                  community.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${followersLabel(community.members)} Pengikut',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Material(
          color: AppColors.followButton, // same grey for Ikuti & Mengikuti
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggleFollow,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                isFollowing ? 'Mengikuti' : 'Ikuti',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
