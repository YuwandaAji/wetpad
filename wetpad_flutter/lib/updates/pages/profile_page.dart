import 'package:flutter/material.dart';

import '../data/profile_action_store.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';
import '../utils/share_helper.dart';
import '../widgets/about_tab.dart';
import '../widgets/conversation_tab.dart';
import '../widgets/profile_action_dialog.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_header.dart';
import '../services/profile_api.dart';
import '../data/profile_store.dart';
import '../data/profiles_data.dart';
import 'edit_profile_page.dart';

void openProfile(BuildContext context, Profile profile) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => profile.isMe
          ? const MyProfilePage()
          : ProfilePage(profile: profile),
    ),
  );
}

/// Profil sendiri: otomatis ter-update saat ProfileStore berubah.
class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ProfileStore.instance,
    builder: (context, _) => ProfilePage(profile: ProfilesData.me),
  );
}

/// Buka profil user/penulis dari database lewat username.
void openProfileByUsername(BuildContext context, String username) {
  final future = ProfileApi.fetch(username); // dipanggil sekali saja
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => FutureBuilder<Profile>(
        future: future,
        builder: (context, snap) {
          if (snap.hasData) return ProfilePage(profile: snap.data!);
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: snap.hasError
                  ? Text(
                      'Gagal memuat profil.\n${snap.error}',
                      textAlign: TextAlign.center,
                    )
                  : const CircularProgressIndicator(),
            ),
          );
        },
      ),
    ),
  );
}

class ProfilePage extends StatelessWidget {
  final Profile profile;
  final int initialTabIndex;
  final String? initialPostId;

  const ProfilePage({
    super.key,
    required this.profile,
    this.initialTabIndex = 0,
    this.initialPostId,
  });

  static const double _expanded = 330; // tinggi header (di luar status bar)
  static const double _toolbar = 56;

  Future<void> _inviteFriends(BuildContext context) =>
      inviteFriends(context, profile.username);

  Future<void> _showProfileAvatar(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatar(profile: profile, size: 200, ring: true),
              const SizedBox(height: 16),
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '@${profile.username}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleProfileAction(BuildContext context, String action) async {
    final actions = ProfileActionStore.instance;
    switch (action) {
      case 'share':
        await shareContent(
          context,
          text: '${profile.name} di Wetpad\n$_profileLink',
          subject: profile.name,
          copiedMessage: 'Tautan profil disalin.',
        );
      case 'mute':
        actions.muteProfile(profile.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${profile.name} telah disenyapkan. Tentang dan Percakapan disembunyikan. Kamu dapat membatalkan senyap kapan saja.',
            ),
          ),
        );
      case 'block':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Blokir ${profile.name}?'),
            content: Text(
              'Akun ini sekarang tidak dapat mengikuti, mengirim pesan pribadi, memosting di profil, atau membaca dan mengomentari cerita kamu. Bagian Tentang dan Percakapan juga disembunyikan. Kamu dapat membatalkan blokir kapan saja.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Blokir'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          actions.blockProfile(profile.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${profile.name} telah diblokir. Tentang dan Percakapan disembunyikan. Kamu dapat membatalkan blokir kapan saja.',
              ),
            ),
          );
        }
      case 'unmute':
        final confirmed = await confirmProfileActionCancellation(
          context,
          profile,
          isBlocked: false,
        );
        if (confirmed && context.mounted) {
          actions.cancelMute(profile.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                profileActionCancellationMessage(profile, isBlocked: false),
              ),
            ),
          );
        }
      case 'unblock':
        final confirmed = await confirmProfileActionCancellation(
          context,
          profile,
          isBlocked: true,
        );
        if (confirmed && context.mounted) {
          actions.unblockProfile(profile.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                profileActionCancellationMessage(profile, isBlocked: true),
              ),
            ),
          );
        }
      case 'report':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Laporkan profil'),
            content: Text(
              'Apakah Anda ingin melaporkan profil ${profile.name} kepada tim Wattpad?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Laporkan'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          actions.reportProfile(profile.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil dilaporkan.')),
          );
        }
    }
  }

  String get _profileLink => profileShareLink(profile.username);

  @override
  Widget build(BuildContext context) {
    final tabs = profile.tabs;
    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialTabIndex.clamp(0, tabs.length - 1),
      child: Scaffold(
        body: AnimatedBuilder(
          animation: ProfileActionStore.instance,
          builder: (context, _) {
            final actions = ProfileActionStore.instance;
            final isBlocked = actions.isBlocked(profile.id);
            final isMuted = actions.isMuted(profile.id);
            final isRestricted = isBlocked || isMuted;
            return NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  toolbarHeight: _toolbar,
                  expandedHeight: _expanded,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, c) {
                      final top = MediaQuery.of(context).padding.top;
                      final minH = _toolbar + top;
                      final maxH = _expanded + top;
                      // t = 1 saat header terbuka penuh, 0 saat menciut jadi AppBar gelap
                      final t = ((c.maxHeight - minH) / (maxH - minH)).clamp(
                        0.0,
                        1.0,
                      );
                      final iconColor = Color.lerp(
                        AppColors.textPrimary,
                        Colors.white,
                        t,
                      )!;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ColoredBox(
                              color: Color.lerp(
                                AppColors.background,
                                profile.bannerColor,
                                t,
                              )!,
                            ),
                          ),
                          Positioned(
                            top: top + 48,
                            left: 16,
                            right: 16,
                            child: IgnorePointer(
                              ignoring: t <= 0.01,
                              child: Opacity(
                                opacity: t,
                                child: ProfileHeaderContent(
                                  profile: profile,
                                  actionsDisabled: isRestricted,
                                  onAvatarTap: () =>
                                      _showProfileAvatar(context),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: top,
                            left: 0,
                            right: 0,
                            height: _toolbar,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: iconColor,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                ),
                                Expanded(
                                  child: Opacity(
                                    opacity: (1 - t * 2).clamp(0.0, 1.0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: Text(
                                        profile.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                                                if (profile.isMe)
                                  IconButton(
                                    tooltip: 'Pengaturan',
                                    icon: Icon(Icons.settings, color: iconColor),
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const EditProfilePage(),
                                      ),
                                    ),
                                  )
                                else
                                  PopupMenuButton<String>(
                                    tooltip: 'Opsi profil',
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: iconColor,
                                    ),
                                    onSelected: (action) =>
                                        _handleProfileAction(context, action),
                                    itemBuilder: (context) {
                                      if (isRestricted) {
                                        return [
                                          if (isMuted)
                                            const PopupMenuItem(
                                              value: 'unmute',
                                              child: Text('Batalkan senyap'),
                                            ),
                                          if (isBlocked)
                                            const PopupMenuItem(
                                              value: 'unblock',
                                              child: Text('Batal blokir'),
                                            ),
                                        ];
                                      }
                                      return const [
                                        PopupMenuItem(
                                          value: 'share',
                                          child: Text('Bagikan profil'),
                                        ),
                                        PopupMenuItem(
                                          value: 'mute',
                                          child: Text('Senyapkan'),
                                        ),
                                        PopupMenuItem(
                                          value: 'block',
                                          child: Text('Blokir'),
                                        ),
                                        PopupMenuItem(
                                          value: 'report',
                                          child: Text('Laporkan'),
                                        ),
                                      ];
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (!isRestricted)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      height: 46,
                      child: Container(
                        color: AppColors.tabBackground,
                        child: TabBar(
                          labelColor: AppColors.textPrimary,
                          unselectedLabelColor: AppColors.textPrimary,
                          indicatorColor: AppColors.orange,
                          indicatorWeight: 4,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0.4,
                          ),
                          tabs: [
                            for (final t in tabs)
                              Tab(height: 46, text: t.label),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
              body: isRestricted
                  ? const _RestrictedProfileBody()
                  : TabBarView(
                      children: [
                        AboutTab(profile: profile),
                        ConversationTab(
                          profile: profile,
                          initialPostId: initialPostId,
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _RestrictedProfileBody extends StatelessWidget {
  const _RestrictedProfileBody();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      key: ValueKey('restricted-profile-body'),
      color: Color(0xFFAAAAAA),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _TabBarDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox(height: height, child: child);

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) =>
      old.child != child || old.height != height;
}
