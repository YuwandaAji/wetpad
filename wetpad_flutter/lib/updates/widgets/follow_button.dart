import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = Colors.white;
    return Material(
      color: isFollowing ? AppColors.followButton : const Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: isFollowing ? AppColors.border : Colors.white,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 146,
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFollowing ? Icons.how_to_reg : Icons.person_add_alt_1,
                size: 22,
                color: fg,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  isFollowing ? 'Mengikuti' : 'Ikuti',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
