import 'package:flutter/material.dart';

import '../screens/library_data.dart';
import 'library_style.dart';
import 'story_cover.dart';

/// Item story mode grid (cover + progress + ikon download + judul).
class StoryGridItem extends StatelessWidget {
  const StoryGridItem({
    super.key,
    required this.story,
    required this.onTap,
    this.onLongPress,
    this.onDownloadTap,
    this.showProgress = true,
    this.editMode = false,
    this.selected = false,
  });

  final LibraryStory story;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDownloadTap;
  final bool showProgress;
  final bool editMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                StoryCover(
                    title: story.title,
                    author: story.author,
                    coverUrl: story.coverUrl),
                if (editMode && selected)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: const ColoredBox(color: Color(0x66000000)),
                  ),
                if (editMode)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? LibColors.orange : Colors.black54,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: selected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          if (showProgress)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: story.progress.clamp(0.0, 1.0),
                        minHeight: 2.5,
                        color: LibColors.orange,
                        backgroundColor: LibColors.border,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkResponse(
                    onTap: onDownloadTap,
                    radius: 20,
                    child: Icon(
                      story.isOffline
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_download_outlined,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: showProgress ? 2 : 8),
            child: Text(
              story.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, height: 1.3, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Item story mode list (baris).
class StoryListItem extends StatelessWidget {
  const StoryListItem({
    super.key,
    required this.story,
    required this.onTap,
    this.onLongPress,
    this.onDownloadTap,
    this.showProgress = true,
    this.editMode = false,
    this.selected = false,
  });

  final LibraryStory story;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDownloadTap;
  final bool showProgress;
  final bool editMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (editMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? LibColors.orange : LibColors.textSecondary,
                ),
              ),
            SizedBox(
              width: 58,
              height: 90,
              child: StoryCover(
                  title: story.title,
                  author: story.author,
                  coverUrl: story.coverUrl),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(story.author,
                      style: const TextStyle(
                          fontSize: 14, color: LibColors.textSecondary)),
                  if (showProgress) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: story.progress.clamp(0.0, 1.0),
                        minHeight: 2.5,
                        color: LibColors.orange,
                        backgroundColor: LibColors.border,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showProgress)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: InkResponse(
                  onTap: onDownloadTap,
                  child: Icon(
                    story.isOffline
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_download_outlined,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Kumpulan story: grid 3 kolom atau list, sesuai [viewMode].
class StoryCollection extends StatelessWidget {
  const StoryCollection({
    super.key,
    required this.stories,
    required this.viewMode,
    required this.onTap,
    this.onLongPress,
    this.onDownloadTap,
    this.showProgress = true,
    this.editMode = false,
    this.selectedIds = const {},
    this.columns = 3,
    this.spacing = 20,
  });

  final List<LibraryStory> stories;
  final LibraryViewMode viewMode;
  final void Function(LibraryStory) onTap;
  final void Function(LibraryStory)? onLongPress;
  final void Function(LibraryStory)? onDownloadTap;
  final bool showProgress;
  final bool editMode;
  final Set<String> selectedIds;
  final int columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (viewMode == LibraryViewMode.list) {
      return Column(
        children: [
          for (final s in stories)
            StoryListItem(
              story: s,
              showProgress: showProgress,
              editMode: editMode,
              selected: selectedIds.contains(s.id),
              onTap: () => onTap(s),
              onLongPress: onLongPress == null ? null : () => onLongPress!(s),
              onDownloadTap:
                  onDownloadTap == null ? null : () => onDownloadTap!(s),
            ),
        ],
      );
    }
    return LayoutBuilder(builder: (context, c) {
      final itemWidth = (c.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: 24,
        children: [
          for (final s in stories)
            SizedBox(
              width: itemWidth,
              child: StoryGridItem(
                story: s,
                showProgress: showProgress,
                editMode: editMode,
                selected: selectedIds.contains(s.id),
                onTap: () => onTap(s),
                onLongPress: onLongPress == null ? null : () => onLongPress!(s),
                onDownloadTap:
                    onDownloadTap == null ? null : () => onDownloadTap!(s),
              ),
            ),
        ],
      );
    });
  }
}
