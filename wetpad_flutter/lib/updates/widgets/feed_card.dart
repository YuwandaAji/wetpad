import 'package:flutter/material.dart';

import '../data/profiles_data.dart';
import '../models/feed_item.dart';
import '../pages/profile_page.dart';
import '../theme/app_theme.dart';
import 'community_avatar.dart';
import 'story_cover.dart';
import 'story_horizontal_card.dart';

class FeedCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onTap;

  const FeedCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(item: item),
          const SizedBox(height: 12),
          switch (item.type) {
            FeedItemType.comment => _CommentBody(item: item),
            FeedItemType.communityPost => _CommunityPostBody(
              item: item,
              onOpenPost: onTap,
            ),
            FeedItemType.readingListAdded ||
            FeedItemType.newReadingList => _ReadingListBody(item: item),
          },
        ],
      ),
    );
    if (item.type == FeedItemType.communityPost) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

class _Header extends StatelessWidget {
  final FeedItem item;
  const _Header({required this.item});

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontSize: 14,
      color: AppColors.textPrimary,
      height: 1.25,
    );
    const bold = TextStyle(fontWeight: FontWeight.w800);

    late final List<InlineSpan> spans;
    switch (item.type) {
      case FeedItemType.readingListAdded:
        spans = [
          TextSpan(text: item.community.name, style: bold),
          TextSpan(
            text: ' menambahkan ${item.storyCount} cerita ke daftar bacaan',
          ),
        ];
        break;
      case FeedItemType.comment:
        spans = [
          TextSpan(text: item.community.name, style: bold),
          const TextSpan(text: ' berkomentar di '),
          TextSpan(text: item.targetName ?? '', style: bold),
        ];
        break;
      case FeedItemType.newReadingList:
        spans = [
          TextSpan(text: item.community.name, style: bold),
          const TextSpan(text: ' membuat daftar bacaan baru'),
        ];
        break;
      case FeedItemType.communityPost:
        spans = [
          TextSpan(text: item.community.name, style: bold),
          const TextSpan(text: ' memposting pesan'),
        ];
        break;
    }

    return InkWell(
      onTap: () =>
          openProfile(context, ProfilesData.fromCommunity(item.community)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityAvatar(community: item.community, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(TextSpan(style: base, children: spans)),
            ),
            const SizedBox(width: 8),
            Text(
              item.timeAgo,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostBody extends StatefulWidget {
  final FeedItem item;
  final VoidCallback? onOpenPost;

  const _CommunityPostBody({required this.item, required this.onOpenPost});

  @override
  State<_CommunityPostBody> createState() => _CommunityPostBodyState();
}

class _CommunityPostBodyState extends State<_CommunityPostBody> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.commentText ?? '',
            maxLines: _expanded ? null : 2,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              height: 1.35,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FeedAction(
                label: _expanded ? 'LIHAT LEBIH SEDIKIT' : 'LIHAT LEBIH LANJUT',
                onTap: () => setState(() => _expanded = !_expanded),
              ),
              _FeedAction(
                label: '${item.commentCount} komentar',
                onTap: widget.onOpenPost,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _FeedAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.link,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ReadingListBody extends StatelessWidget {
  final FeedItem item;
  const _ReadingListBody({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (item.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  item.subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: item.stories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => StoryHorizontalCard(story: item.stories[i]),
          ),
        ),
      ],
    );
  }
}

class _CommentBody extends StatelessWidget {
  final FeedItem item;
  const _CommentBody({required this.item});

  @override
  Widget build(BuildContext context) {
    final story = item.stories.isNotEmpty ? item.stories.first : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (story != null) ...[
            StoryCover(story: story, width: 50, height: 78),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.community.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.commentText ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
