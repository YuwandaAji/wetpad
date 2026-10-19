import 'package:flutter/material.dart';

import '../data/communities_data.dart';
import '../data/follow_store.dart';
import '../data/profiles_data.dart';
import '../models/community.dart';
import '../pages/profile_page.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/community_avatar.dart';
import '../widgets/follow_button.dart';

class CommunityDiscoveryPage extends StatelessWidget {
  const CommunityDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = FollowStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Temukan komunitas')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: CommunitiesData.all.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final community = CommunitiesData.all[index];
            return _CommunityRow(community: community);
          },
        ),
      ),
    );
  }
}

class _CommunityRow extends StatelessWidget {
  final Community community;

  const _CommunityRow({required this.community});

  @override
  Widget build(BuildContext context) {
    final store = FollowStore.instance;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CommunityAvatar(community: community, size: 48),
      title: Text(
        community.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${followersLabel(community.members)} Pengikut\n${community.description}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      isThreeLine: true,
      onTap: () => openProfile(context, ProfilesData.fromCommunity(community)),
      trailing: AnimatedBuilder(
        animation: store,
        builder: (context, _) => FollowButton(
          isFollowing: store.isFollowing(community.id),
          onTap: () => store.toggle(community.id),
        ),
      ),
    );
  }
}
