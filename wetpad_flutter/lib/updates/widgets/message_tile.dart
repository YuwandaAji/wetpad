import 'package:flutter/material.dart';

import '../models/message_item.dart';
import '../theme/app_theme.dart';

class MessageTile extends StatelessWidget {
  final MessageItem item;
  const MessageTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.orange,
        child: Text(item.sender.isEmpty ? '?' : item.sender[0].toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      title: Text(item.sender,
          style: TextStyle(
              fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w800)),
      subtitle:
          Text(item.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(item.timeAgo,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    );
  }
}
