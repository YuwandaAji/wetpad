import 'package:flutter/material.dart';

import '../models/notification_item.dart';
import '../theme/app_theme.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.item, this.onTap});

  IconData get _icon {
    switch (item.type) {
      case NotificationType.follow:
        return Icons.person_add_alt_1;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.storyUpdate:
        return Icons.menu_book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isRead ? null : const Color(0xFFFFF4EE),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.chip,
              child: Icon(_icon, color: AppColors.orange, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              item.isRead ? FontWeight.w500 : FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(item.timeAgo,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                margin: const EdgeInsets.only(top: 6, left: 8),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: AppColors.orange, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
