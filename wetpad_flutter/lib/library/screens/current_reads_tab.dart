import 'package:flutter/material.dart';

import '../widgets/library_sections.dart';
import '../widgets/library_style.dart';
import '../widgets/story_item.dart';
import 'library_data.dart';

/// Tab "CURRENT READS". Stateless: semua data & aksi datang dari LibraryScreen.
class CurrentReadsTab extends StatelessWidget {
  const CurrentReadsTab({
    super.key,
    required this.totalCount,
    required this.offline,
    required this.saved,
    required this.sort,
    required this.viewMode,
    required this.editMode,
    required this.selectedIds,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onSortTap,
    required this.onViewModeTap,
    required this.onStoryTap,
    required this.onStoryMenu,
    required this.onToggleOffline,
    required this.onBrowse,
    required this.onTopicTap,
  });

  final int totalCount;
  final List<LibraryStory> offline;
  final List<LibraryStory> saved;
  final LibrarySort sort;
  final LibraryViewMode viewMode;
  final bool editMode;
  final Set<String> selectedIds;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onSortTap;
  final VoidCallback onViewModeTap;
  final void Function(LibraryStory) onStoryTap;
  final void Function(LibraryStory) onStoryMenu;
  final void Function(LibraryStory) onToggleOffline;
  final VoidCallback onBrowse;
  final void Function(String) onTopicTap;

  // TODO(API): ambil dari endpoint rekomendasi topik.
  static const _topics = ['chemistry', 'danger', 'darkromance', 'enemiestolovers'];

  Widget _collection(List<LibraryStory> stories) => StoryCollection(
        stories: stories,
        viewMode: viewMode,
        editMode: editMode,
        selectedIds: selectedIds,
        onTap: onStoryTap,
        onLongPress: onStoryMenu,
        onDownloadTap: onToggleOffline,
      );

  @override
  Widget build(BuildContext context) {
    if (isLoading && totalCount == 0) {
      return const Center(
          child: CircularProgressIndicator(color: LibColors.orange));
    }
    return RefreshIndicator(
      color: LibColors.orange,
      backgroundColor: LibColors.tabBar,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          LibraryToolbar(
            storyCount: totalCount,
            sort: sort,
            viewMode: viewMode,
            onSortTap: onSortTap,
            onViewModeTap: onViewModeTap,
          ),
          const SizedBox(height: 28),
          SectionHeader(
              title: 'Available Offline',
              trailing: SectionHeader.storyCount(offline.length)),
          const SizedBox(height: 16),
          if (offline.isEmpty) const OfflineEmptyCard() else _collection(offline),
          const SizedBox(height: 32),
          SectionHeader(
              title: 'Saved Stories',
              trailing: SectionHeader.storyCount(saved.length)),
          const SizedBox(height: 16),
          if (saved.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No saved stories yet.',
                  style: TextStyle(color: LibColors.textSecondary)),
            )
          else
            _collection(saved),
          const SizedBox(height: 32),
          OriginalsPromoCard(onBrowse: onBrowse),
          const SizedBox(height: 32),
          TopicChips(topics: _topics, onTap: onTopicTap),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }
}
