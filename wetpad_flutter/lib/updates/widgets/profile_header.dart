import 'package:flutter/material.dart';

import '../data/follow_store.dart';
import '../data/library_store.dart';
import '../data/profile_action_store.dart';
import '../models/profile.dart';
import '../pages/profile_stats_page.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'follow_button.dart';
import 'profile_avatar.dart';
import 'profile_action_dialog.dart';

/// Isi header gelap (di bawah baris toolbar).
class ProfileHeaderContent extends StatelessWidget {
  final Profile profile;
  final bool actionsDisabled;

  const ProfileHeaderContent({
    super.key,
    required this.profile,
    this.actionsDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final store = FollowStore.instance;
    final p = profile;
    void openStats(ProfileStatsSection section) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfileStatsPage(profile: p, section: section),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProfileAvatar(profile: p, size: 92, ring: true),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            if (p.isOfficial) ...[
              const SizedBox(width: 10),
              const _Badge(Icons.check),
              const SizedBox(width: 6),
              const _Badge(Icons.favorite),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '@${p.username}',
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        if (p.isMe)
          const _CoinPill()
        else
          AnimatedBuilder(
            animation: ProfileActionStore.instance,
            builder: (context, _) {
              final actions = ProfileActionStore.instance;
              if (actions.isBlocked(p.id)) {
                return _RestoreProfileActionButton(
                  label: 'Batal blokir',
                  icon: Icons.block,
                  onTap: () async {
                    final confirmed = await confirmProfileActionCancellation(
                      context,
                      p,
                      isBlocked: true,
                    );
                    if (!confirmed || !context.mounted) return;
                    actions.unblockProfile(p.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          profileActionCancellationMessage(p, isBlocked: true),
                        ),
                      ),
                    );
                  },
                );
              }
              if (actions.isMuted(p.id)) {
                return _RestoreProfileActionButton(
                  label: 'Batalkan senyap',
                  icon: Icons.volume_off,
                  onTap: () async {
                    final confirmed = await confirmProfileActionCancellation(
                      context,
                      p,
                      isBlocked: false,
                    );
                    if (!confirmed || !context.mounted) return;
                    actions.cancelMute(p.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          profileActionCancellationMessage(p, isBlocked: false),
                        ),
                      ),
                    );
                  },
                );
              }
              return AnimatedBuilder(
                animation: store,
                builder: (context, _) => FollowButton(
                  isFollowing: store.isFollowing(p.id),
                  onTap: () => store.toggle(p.id),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: LibraryStore.instance,
          builder: (context, _) => SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (p.type != ProfileType.user)
                  Expanded(
                    child: _Stat(
                      value: '${p.publishedCount}',
                      label: 'KARYA',
                      onTap: () => openStats(ProfileStatsSection.stories),
                      enabled: !actionsDisabled,
                    ),
                  ),
                Expanded(
                  child: _Stat(
                    value:
                        '${p.isMe ? LibraryStore.instance.readingListsFor(p).length : p.readingListCount}',
                    label: 'DAFTAR BACAAN',
                    onTap: () => openStats(ProfileStatsSection.readingLists),
                    enabled: !actionsDisabled,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    value: idCompact(p.followers),
                    label: 'PENGIKUT',
                    onTap: () => openStats(ProfileStatsSection.followers),
                    enabled: !actionsDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RestoreProfileActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _RestoreProfileActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: ValueKey('restore-profile-action-$label'),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(190, 44),
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.followButton,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  const _Badge(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFFFF5A12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 14, color: Colors.white),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.followButton,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC107),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 22),
          const Text('0', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 18),
          Container(width: 1, height: 32, color: AppColors.border),
          const SizedBox(width: 12),
          const Icon(Icons.add, size: 18),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _Stat({
    required this.value,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: enabled,
      label: '$label $value',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    color: enabled ? Colors.white : Colors.white54,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: enabled ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
