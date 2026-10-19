import 'package:flutter/material.dart';

import '../data/notifications_data.dart';
import '../models/notification_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab>
    with AutomaticKeepAliveClientMixin {
  late final List<NotificationItem> _items = [...NotificationsData.items];

  @override
  bool get wantKeepAlive => true;

  void _markRead(int index) {
    setState(() => _items[index] = _items[index].copyWith(isRead: true));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_items.isEmpty) {
      return const EmptyState(
        boldTitle: false,
        title: 'Belum ada notifikasi apa pun saat ini.',
        subtitle:
            'Pembaruan cerita di perpustakaan dan cerita dari profil yang kamu ikuti akan muncul di sini.',
      );
    }

    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) =>
          NotificationTile(item: _items[i], onTap: () => _markRead(i)),
    );
  }
}
