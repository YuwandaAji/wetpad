import 'package:flutter/material.dart';

import '../../readmode/open_story.dart';
import '../models/notification_item.dart';
import '../services/notifications_api.dart';
import '../widgets/empty_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab>
    with AutomaticKeepAliveClientMixin {
  List<NotificationItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await NotificationsApi.fetch();
      if (!mounted) return;
      setState(() {
        _items = list;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }

  void _onTap(int i) {
    final n = _items[i];
    if (!n.isRead) {
      setState(() => _items[i] = n.copyWith(isRead: true)); // langsung tampil terbaca
      NotificationsApi.markRead(n.id);
    }
    if (n.storyId != null) openStoryFromSearch(context, n.storyId!);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(onPressed: _retry, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: _items.isEmpty
          ? ListView(
              children: const [
                SizedBox(
                  height: 420,
                  child: EmptyState(
                    boldTitle: false,
                    title: 'Belum ada notifikasi apa pun saat ini.',
                    subtitle:
                        'Pembaruan cerita di perpustakaan dan cerita dari profil yang kamu ikuti akan muncul di sini.',
                  ),
                ),
              ],
            )
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) =>
                  NotificationTile(item: _items[i], onTap: () => _onTap(i)),
            ),
    );
  }
}