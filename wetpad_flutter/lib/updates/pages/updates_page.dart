import 'package:flutter/material.dart';

import '../utils/share_helper.dart';

import '../data/profiles_data.dart';
import '../theme/app_theme.dart';
import 'messages_tab.dart';
import 'notifications_tab.dart';
import 'social_feed_tab.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
<<<<<<< Updated upstream
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          title: const Text(
            'Updates',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          actions: [
            IconButton(
              key: const ValueKey('invite-friends'),
              tooltip: 'Salin tautan profil untuk mengundang teman',
              onPressed: () async {
                final link =
                    'https://www.wattpad.com/user/${Uri.encodeComponent(ProfilesData.me.username)}';
                await Clipboard.setData(ClipboardData(text: link));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tautan profil disalin. Bagikan kepada temanmu!',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.person_add_alt_1, size: 26),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.tabBackground,
              child: const TabBar(
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textPrimary,
                indicatorColor: AppColors.orange,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(fontSize: 14, letterSpacing: 0.4),
                tabs: [
                  Tab(height: 46, text: 'FEED SOSIAL'),
                  Tab(height: 46, text: 'NOTIFIKASI'),
                  Tab(height: 46, text: 'PESAN'),
                ],
=======
    return Theme(
      data: AppTheme.dark,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: const Text(
              'Updates',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            actions: [
              IconButton(
                key: const ValueKey('invite-friends'),
                tooltip: 'Undang teman',
                onPressed: () =>
                    inviteFriends(context, ProfilesData.me.username),
                icon: const Icon(Icons.person_add_alt_1, size: 26),
>>>>>>> Stashed changes
=======
    return Theme(
      data: AppTheme.dark,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: const Text(
              'Updates',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            actions: [
              IconButton(
                key: const ValueKey('invite-friends'),
                tooltip: 'Salin tautan profil untuk mengundang teman',
                onPressed: () async {
                  final link =
                      'https://www.wattpad.com/user/${Uri.encodeComponent(ProfilesData.me.username)}';
                  await Clipboard.setData(ClipboardData(text: link));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tautan profil disalin. Bagikan kepada temanmu!',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.person_add_alt_1, size: 26),
>>>>>>> main
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: Column(
            children: [
              Container(
                color: AppColors.tabBackground,
                child: const TabBar(
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textPrimary,
                  indicatorColor: AppColors.orange,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(fontSize: 14, letterSpacing: 0.4),
                  tabs: [
                    Tab(height: 46, text: 'FEED SOSIAL'),
                    Tab(height: 46, text: 'NOTIFIKASI'),
                    Tab(height: 46, text: 'PESAN'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    SocialFeedTab(),
                    NotificationsTab(),
                    MessagesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
