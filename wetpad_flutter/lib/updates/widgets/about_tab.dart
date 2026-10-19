import 'package:flutter/material.dart';

import '../data/library_store.dart';
import '../models/profile.dart';
import '../models/story.dart';
import '../pages/profile_page.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'profile_avatar.dart';
import 'profile_story_card.dart';

class AboutTab extends StatelessWidget {
  final Profile profile;
  const AboutTab({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final showStories = p.stories.isNotEmpty || p.isMe;
    return AnimatedBuilder(
      animation: LibraryStore.instance,
      builder: (context, _) {
        final readingLists = p.isMe
            ? LibraryStore.instance.readingListsFor(p)
            : p.readingLists;
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _AboutText(profile: p),
            const Divider(height: 1),
            if (showStories) ...[
              _SectionTitle(
                title: 'Cerita oleh ${p.username}',
                subtitle: '${p.publishedCount} Cerita Terpublikasi',
              ),
              _StoryRow(stories: p.stories),
              const SizedBox(height: 20),
            ],
            if (p.followingProfiles.isNotEmpty) ...[
              const Divider(height: 1),
              _SectionTitle(
                title: 'Mengikuti',
                subtitle: '${p.following} Profil',
              ),
              SizedBox(
                height: 124,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: p.followingProfiles.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, i) =>
                      _FollowingItem(profile: p.followingProfiles[i]),
                ),
              ),
              const SizedBox(height: 20),
            ],
            for (final list in readingLists) ...[
              const Divider(height: 1),
              _SectionTitle(
                title: list.title,
                subtitle: 'Daftar Bacaan • ${list.stories.length} Cerita',
              ),
              _StoryRow(stories: list.stories),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

/// Deskripsi dengan "lebih banyak".
class _AboutText extends StatefulWidget {
  final Profile profile;
  const _AboutText({required this.profile});

  @override
  State<_AboutText> createState() => _AboutTextState();
}

class _AboutTextState extends State<_AboutText> {
  bool _expanded = false;
  static const _limit = 110;

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final empty = p.about.trim().isEmpty;
    final text = empty
        ? 'Ketuk di sini untuk menambahkan deskripsi tentang diri kamu…'
        : p.about;
    final truncated = !_expanded && text.length > _limit;
    final shown = truncated
        ? '${text.substring(0, _limit).trimRight()}…'
        : text;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(text: shown),
                  if (truncated)
                    const TextSpan(
                      text: ' lebih banyak',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
          if (p.joinedLabel.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              p.joinedLabel,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryRow extends StatelessWidget {
  final List<Story> stories;
  const _StoryRow({required this.stories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, i) => ProfileStoryCard(story: stories[i]),
      ),
    );
  }
}

class _FollowingItem extends StatelessWidget {
  final Profile profile;
  const _FollowingItem({required this.profile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openProfile(context, profile),
      child: SizedBox(
        width: 112,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatar(profile: profile, size: 66),
            const SizedBox(height: 8),
            Text(
              profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${idCompact(profile.followers)} Pengikut',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
