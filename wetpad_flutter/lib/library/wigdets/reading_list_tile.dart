import 'package:flutter/material.dart';

import '../screens/library_data.dart';
import 'library_style.dart';
import 'story_cover.dart';

enum ReadingListMenuAction { rename, share, delete }

class _CountAndPrivacy extends StatelessWidget {
  const _CountAndPrivacy({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style:
                const TextStyle(fontSize: 15, color: LibColors.textSecondary)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.circle, size: 5, color: LibColors.textSecondary),
        ),
        Icon(icon, size: 20, color: LibColors.textSecondary),
      ],
    );
  }
}

class LikedListsTile extends StatelessWidget {
  const LikedListsTile({super.key, required this.count, this.onTap});
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 110,
        child: Row(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: LibColors.likedTile,
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  const Icon(Icons.favorite, color: LibColors.orange, size: 34),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Liked reading lists',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  _CountAndPrivacy(
                      text: count == 1 ? '1 list' : '$count lists',
                      icon: Icons.lock_outline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingListTile extends StatelessWidget {
  const ReadingListTile({
    super.key,
    required this.list,
    required this.stories,
    required this.onTap,
    required this.onMenuSelected,
  });

  final LibraryReadingList list;
  final List<LibraryStory> stories;
  final VoidCallback onTap;
  final void Function(ReadingListMenuAction) onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final n = list.storyIds.length;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 110,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Collage(stories: stories),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(list.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  _CountAndPrivacy(
                    text: n == 1 ? '1 story' : '$n stories',
                    icon: list.isPublic ? Icons.public : Icons.lock_outline,
                  ),
                ],
              ),
            ),
            PopupMenuButton<ReadingListMenuAction>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, color: LibColors.textSecondary),
              onSelected: onMenuSelected,
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: ReadingListMenuAction.rename, child: Text('Rename')),
                const PopupMenuItem(
                    value: ReadingListMenuAction.share, child: Text('Share')),
                const PopupMenuItem(
                    value: ReadingListMenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Collage extends StatelessWidget {
  const _Collage({required this.stories});
  final List<LibraryStory> stories;

  Widget _small(int i) {
    if (i < stories.length) {
      final s = stories[i];
      return StoryCover(title: s.title, author: s.author, coverUrl: s.coverUrl);
    }
    return Container(
      decoration: BoxDecoration(
        color: LibColors.placeholderBox,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Text('w',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: Color(0xFF141414),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Row(
        children: [
          SizedBox(
            width: 73,
            height: 110,
            child: stories.isNotEmpty
                ? StoryCover(
                    title: stories[0].title,
                    author: stories[0].author,
                    coverUrl: stories[0].coverUrl,
                    borderRadius: 4)
                : _small(99),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _small(1)),
                const SizedBox(height: 3),
                Expanded(child: _small(2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
