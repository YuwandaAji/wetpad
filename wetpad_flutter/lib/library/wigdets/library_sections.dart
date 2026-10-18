import 'package:flutter/material.dart';

import '../screens/library_data.dart';
import 'library_style.dart';
import 'story_cover.dart';

// ---------------------------------------------------------- SectionHeader
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});
  final String title;
  final String? trailing;

  static String storyCount(int n) => n == 1 ? '1 Story' : '$n Stories';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        if (trailing != null)
          Text(trailing!,
              style: const TextStyle(
                  fontSize: 16, color: LibColors.textSecondary)),
      ],
    );
  }
}

// ---------------------------------------------------------- LibraryToolbar
class LibraryToolbar extends StatelessWidget {
  const LibraryToolbar({
    super.key,
    required this.storyCount,
    required this.sort,
    required this.viewMode,
    required this.onSortTap,
    required this.onViewModeTap,
  });

  final int storyCount;
  final LibrarySort sort;
  final LibraryViewMode viewMode;
  final VoidCallback onSortTap;
  final VoidCallback onViewModeTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(storyCount == 1 ? '1 story' : '$storyCount stories',
            style:
                const TextStyle(fontSize: 16, color: LibColors.textSecondary)),
        const Spacer(),
        Material(
          color: LibColors.sortPill,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onSortTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert, size: 20),
                  const SizedBox(width: 8),
                  Text(sort.label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkResponse(
          onTap: onViewModeTap,
          radius: 24,
          child: Icon(
            viewMode == LibraryViewMode.grid
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded,
            size: 30,
          ),
        ),
      ],
    );
  }
}

Future<LibrarySort?> showSortSheet(BuildContext context, LibrarySort current) {
  return showModalBottomSheet<LibrarySort>(
    context: context,
    backgroundColor: LibColors.background,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Sort by',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 30),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
          for (final s in LibrarySort.values)
            InkWell(
              onTap: () => Navigator.pop(ctx, s),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(s.label,
                            style: const TextStyle(fontSize: 18))),
                    Icon(
                      s == current
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 30,
                      color: s == current ? LibColors.orange : Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

// ------------------------------------------------------- OfflineEmptyCard
class OfflineEmptyCard extends StatelessWidget {
  const OfflineEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: LibColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E2420),
                    borderRadius: BorderRadius.all(Radius.elliptical(110, 80)),
                  ),
                ),
                const Positioned(
                    left: 6,
                    top: 10,
                    child: Icon(Icons.accessibility_new,
                        size: 34, color: Color(0xFF8E8AB8))),
                const Positioned(
                    top: 4,
                    child: Icon(Icons.accessibility_new,
                        size: 34, color: Colors.white)),
                const Positioned(
                    right: 6,
                    top: 10,
                    child: Icon(Icons.accessibility_new,
                        size: 34, color: Color(0xFFE59AA8))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Stories added to your Offline list will appear here.',
                style: TextStyle(fontSize: 16, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------ OriginalsPromoCard
class OriginalsPromoCard extends StatelessWidget {
  const OriginalsPromoCard({super.key, required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: LibColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 81,
            height: 125,
            child: StoryCover(
                title: 'Underground', author: 'babezcanwrite', borderRadius: 2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wattpad Originals',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                  'Read the hottest stories handpicked by editorial experts.',
                  style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: LibColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Material(
                  color: Colors.white,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: onBrowse,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Text('Browse',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ),
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

// -------------------------------------------------------------- TopicChips
class TopicChips extends StatelessWidget {
  const TopicChips({super.key, required this.topics, required this.onTap});
  final List<String> topics;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Find more stories about',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => Material(
              color: LibColors.chip,
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onTap(topics[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: Text(topics[i],
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------ AdBannerPlaceholder
class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: LibColors.tabBar,
          border: Border.all(color: LibColors.border),
        ),
        child: const Text('AD SPACE · 320x50',
            style: TextStyle(fontSize: 12, color: LibColors.textSecondary)),
      ),
    );
  }
}

// ------------------------------------------------------ EditSelectionBar
class EditSelectionBar extends StatelessWidget {
  const EditSelectionBar({
    super.key,
    required this.count,
    required this.onAddToList,
    required this.onArchive,
    required this.onRemove,
  });

  final int count;
  final VoidCallback onAddToList;
  final VoidCallback onArchive;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final enabled = count > 0;
    return Container(
      color: LibColors.tabBar,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _BarAction(
                icon: Icons.playlist_add,
                label: 'Add to reading list ($count)',
                color: Colors.white,
                onTap: enabled ? onAddToList : null),
            _BarAction(
                icon: Icons.archive_outlined,
                label: 'Archive ($count)',
                color: Colors.white,
                onTap: enabled ? onArchive : null),
            _BarAction(
                icon: Icons.delete_outline,
                label: 'Remove ($count)',
                color: LibColors.orange,
                onTap: enabled ? onRemove : null),
          ],
        ),
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = onTap == null ? LibColors.textSecondary : color;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: c),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(fontSize: 12, color: c)),
            ],
          ),
        ),
      ),
    );
  }
}
