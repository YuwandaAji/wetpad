import 'package:flutter/material.dart';

import '../data/communities_data.dart';
import '../data/conversation_store.dart';
import '../data/follow_store.dart';
import '../data/profiles_data.dart';
import '../models/community.dart';
import '../models/feed_item.dart';
import 'profile_page.dart';
import '../theme/app_theme.dart';
import '../widgets/community_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/feed_card.dart';
import '../widgets/section_header.dart';

class SocialFeedTab extends StatefulWidget {
  const SocialFeedTab({super.key});

  @override
  State<SocialFeedTab> createState() => _SocialFeedTabState();
}

class _SocialFeedTabState extends State<SocialFeedTab>
    with AutomaticKeepAliveClientMixin {
  final _followStore = FollowStore.instance;
  final _conversationStore = ConversationStore.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _followStore.seed(CommunitiesData.initiallyFollowedIds);
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedBuilder(
      animation: _followStore,
      builder: (context, _) => AnimatedBuilder(
        animation: _conversationStore,
        builder: (context, _) {
          final followedIds = _followStore.ids;
          final feed = _feedFor(followedIds)
            ..sort((a, b) => a.minutesAgo.compareTo(b.minutesAgo));
          final recommended = CommunitiesData.all
              .where((community) => !followedIds.contains(community.id))
              .toList();
          final children = followedIds.isEmpty
              ? _emptyChildren(recommended)
              : _feedChildren(feed, recommended);
          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: children,
            ),
          );
        },
      ),
    );
  }

  List<FeedItem> _feedFor(Set<String> followedIds) {
    final feed = <FeedItem>[];
    for (final community in CommunitiesData.all) {
      if (!followedIds.contains(community.id)) continue;
      final profile = ProfilesData.fromCommunity(community, deep: false);
      for (final post in _conversationStore.postsFor(profile)) {
        if (post.authorId != community.id) continue;
        feed.add(
          FeedItem(
            id: 'community_post_${post.id}',
            community: community,
            type: FeedItemType.communityPost,
            minutesAgo: post.minutesAgo,
            title: post.text,
            commentText: post.text,
            postId: post.id,
            commentCount: post.replies.length,
          ),
        );
      }
    }
    return feed;
  }

  /// Screen shown when the user follows no one.
  List<Widget> _emptyChildren(List<Community> recommended) {
    return [
      const SizedBox(height: 56),
      const Center(child: FeedEmptyIllustration()),
      const SizedBox(height: 36),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Melalui cerita, kita saling bertemu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      const SizedBox(height: 18),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'Ikuti orang lain untuk menghidupkan feed kamu dan menemukan dunia baru',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      const SizedBox(height: 40),
      ..._communitySection(recommended),
    ];
  }

  /// Screen shown once the user follows at least one community.
  List<Widget> _feedChildren(List<FeedItem> feed, List<Community> recommended) {
    return [
      for (final item in feed) ...[
        FeedCard(
          item: item,
          onTap: item.postId == null ? null : () => _openCommunityPost(item),
        ),
        const _Gap(),
      ],
      if (feed.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'Belum ada pembaruan dari komunitas yang diikuti.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      const _Gap(),
      ..._communitySection(recommended),
    ];
  }

  void _openCommunityPost(FeedItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          profile: ProfilesData.fromCommunity(item.community),
          initialTabIndex: 1,
          initialPostId: item.postId,
        ),
      ),
    );
  }

  /// "Temukan komunitasmu" + 3 columns (shared by both screens).
  List<Widget> _communitySection(List<Community> recommended) {
    if (recommended.isEmpty) return const [];
    return [
      const SectionHeader(title: 'Temukan komunitasmu'),
      SizedBox(
        height: 180,
        child: ListView.separated(
          key: const ValueKey('community-discovery-list'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: recommended.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final community = recommended[index];
            return SizedBox(
              width: 148,
              child: CommunityCard(
                community: community,
                isFollowing: _followStore.isFollowing(community.id),
                onToggleFollow: () => _followStore.toggle(community.id),
                onOpenProfile: () =>
                    openProfile(context, ProfilesData.fromCommunity(community)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 28),
    ];
  }
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) =>
      Container(height: 10, color: AppColors.sectionGap);
}
