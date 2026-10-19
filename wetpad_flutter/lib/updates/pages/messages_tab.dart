import 'package:flutter/material.dart';

import '../data/messages_data.dart';
import '../widgets/empty_state.dart';
import '../widgets/message_tile.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MessagesData.items;

    if (items.isEmpty) {
      return const EmptyState(
        showIllustration: true,
        title: 'Dapatkan berita dan pembaruan dari tim Wattpad',
        subtitle: 'Tidak ada pesan baru.',
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => MessageTile(item: items[i]),
    );
  }
}
