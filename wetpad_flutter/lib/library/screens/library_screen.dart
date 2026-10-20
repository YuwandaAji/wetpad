import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/library_sections.dart';
import '../widgets/library_style.dart';
import '../widgets/reading_list_tile.dart';
import '../widgets/story_dialogs.dart';
import 'archive_tab.dart';
import 'current_reads_tab.dart';
import 'library_data.dart';
import 'reading_list_detail_screen.dart';
import 'reading_lists_tab.dart';
import 'faq_screen.dart';
import '../../readmode/open_story.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, this.repository});
  final LibraryRepository? repository;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final LibraryRepository _repo =
      widget.repository ?? MockLibraryRepository();
  late final TabController _tab = TabController(length: 3, vsync: this);

  List<LibraryStory> _stories = [];
  List<LibraryReadingList> _lists = [];
  final Set<String> _selected = {};

  bool _loading = false;
  String? _error;
  LibrarySort _sort = LibrarySort.recentlyRead;
  LibraryViewMode _viewMode = LibraryViewMode.grid;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _tab.addListener(() {
      if (_tab.index != 0 && _editMode) {
        _editMode = false;
        _selected.clear();
      }
      if (mounted) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // ------------------------------------------------------------ data turunan
  List<LibraryStory> _sorted(Iterable<LibraryStory> input) {
    final list = input.toList();
    switch (_sort) {
      case LibrarySort.recentlyRead:
        list.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
      case LibrarySort.recentlyUpdated:
        list.sort((a, b) =>
            (b.updatedAt ?? b.addedAt).compareTo(a.updatedAt ?? a.addedAt));
      case LibrarySort.recentlyAdded:
        list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      case LibrarySort.storyTitle:
        list.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case LibrarySort.writer:
        list.sort(
            (a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
    }
    return list;
  }

  List<LibraryStory> get _saved =>
      _sorted(_stories.where((s) => !s.isArchived && !s.isOffline));
  List<LibraryStory> get _offline =>
      _sorted(_stories.where((s) => !s.isArchived && s.isOffline));
  List<LibraryStory> get _archived =>
      _sorted(_stories.where((s) => s.isArchived));
  int get _currentCount => _stories.where((s) => !s.isArchived).length;

  List<LibraryStory> _storiesOf(LibraryReadingList l) => [
        for (final id in l.storyIds) ..._stories.where((s) => s.id == id),
      ];

  // ------------------------------------------------------------------- load
  Future<void> _load() async {
    _set(() {
      _loading = true;
      _error = null;
    });
    try {
      final stories = await _repo.fetchStories();
      final lists = await _repo.fetchReadingLists();
      _set(() {
        _stories = stories;
        _lists = lists;
      });
    } catch (e) {
      _set(() => _error = e.toString());
    }
    _set(() => _loading = false);
  }

  // ---------------------------------------------------------- aksi story
  Future<void> _updateStory(
      String id, LibraryStory Function(LibraryStory) change) async {
    final i = _stories.indexWhere((s) => s.id == id);
    if (i < 0) return;
    final old = _stories[i];
    final updated = change(old);
    _set(() => _stories[i] = updated); // optimistic
    try {
      await _repo.saveStory(updated);
    } catch (e) {
      final j = _stories.indexWhere((s) => s.id == id);
      _set(() {
        if (j >= 0) _stories[j] = old; // rollback
        _error = e.toString();
      });
    }
  }

  Future<void> _markRead(String id) =>
      _updateStory(id, (s) => s.copyWith(lastReadAt: DateTime.now()));
  Future<void> _archive(String id) =>
      _updateStory(id, (s) => s.copyWith(isArchived: true));
  Future<void> _unarchive(String id) =>
      _updateStory(id, (s) => s.copyWith(isArchived: false));
  Future<void> _setOffline(String id, bool v) =>
      _updateStory(id, (s) => s.copyWith(isOffline: v));

  Future<void> _unarchiveAll() async {
    for (final s in _archived) {
      await _unarchive(s.id);
    }
  }

  Future<LibraryStory?> _remove(String id) async {
    final i = _stories.indexWhere((s) => s.id == id);
    if (i < 0) return null;
    final story = _stories[i];
    _set(() {
      _stories.removeAt(i);
      _selected.remove(id);
    });
    try {
      await _repo.deleteStory(id);
    } catch (e) {
      _set(() => _error = e.toString());
    }
    return story;
  }

  Future<void> _restore(LibraryStory story) async {
    _set(() => _stories.add(story));
    try {
      await _repo.saveStory(story);
    } catch (e) {
      _set(() => _error = e.toString());
    }
  }

  // ----------------------------------------------------------- mode edit
  void _toggleEdit() => _set(() {
        _editMode = !_editMode;
        _selected.clear();
      });

  void _toggleSelected(String id) => _set(
      () => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));

  Future<void> _archiveSelected() async {
    for (final id in _selected.toList()) {
      await _archive(id);
    }
    _set(() {
      _editMode = false;
      _selected.clear();
    });
  }

  Future<void> _removeSelected() async {
    for (final id in _selected.toList()) {
      await _remove(id);
    }
    _set(() {
      _editMode = false;
      _selected.clear();
    });
  }

  Future<void> _addSelectedToReadingList(BuildContext ctx) async {
    if (_selected.isEmpty) return;
    final ids = _selected.toList();
    final listId = await showPickReadingListDialog(
      ctx,
      lists: _lists,
      onCreate: (name) => _createList(name),
    );
    if (listId == null) return;
    await _updateList(
      listId,
      (l) => l.copyWith(storyIds: [
        ...l.storyIds,
        ...ids.where((id) => !l.storyIds.contains(id)),
      ]),
    );
    _set(() {
      _editMode = false;
      _selected.clear();
    });
    if (ctx.mounted) {
      showAppSnack(
          ctx,
          ids.length == 1
              ? 'Added to reading list'
              : '${ids.length} stories added to reading list');
    }
  }

  // ------------------------------------------------------- reading lists
  Future<String> _createList(String name, {String? withStoryId}) async {
    final list = LibraryReadingList(
      id: 'rl_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      storyIds: withStoryId == null ? [] : [withStoryId],
    );
    _set(() => _lists.add(list));
    try {
      await _repo.saveReadingList(list);
    } catch (e) {
      _set(() => _error = e.toString());
    }
    return list.id;
  }

  Future<void> _updateList(
      String id, LibraryReadingList Function(LibraryReadingList) change) async {
    final i = _lists.indexWhere((l) => l.id == id);
    if (i < 0) return;
    final updated = change(_lists[i]);
    _set(() => _lists[i] = updated);
    try {
      await _repo.saveReadingList(updated);
    } catch (e) {
      _set(() => _error = e.toString());
    }
  }

  Future<void> _toggleStoryInList(String listId, String storyId) =>
      _updateList(listId, (l) {
        final ids = [...l.storyIds];
        ids.contains(storyId) ? ids.remove(storyId) : ids.add(storyId);
        return l.copyWith(storyIds: ids);
      });

  Future<void> _deleteList(String id) async {
    _set(() => _lists.removeWhere((l) => l.id == id));
    try {
      await _repo.deleteReadingList(id);
    } catch (e) {
      _set(() => _error = e.toString());
    }
  }

  Future<void> _onListMenu(
      BuildContext ctx, LibraryReadingList l, ReadingListMenuAction a) async {
    switch (a) {
      case ReadingListMenuAction.rename:
        final name = await showNameDialog(ctx,
            title: 'Rename reading list', initial: l.name);
        if (name != null)
          await _updateList(l.id, (x) => x.copyWith(name: name));
      case ReadingListMenuAction.share:
        await Clipboard.setData(
            ClipboardData(text: 'https://www.wattpad.com/list/${l.id}'));
        if (ctx.mounted) showAppSnack(ctx, 'Reading list link copied');
      case ReadingListMenuAction.delete:
        await _deleteList(l.id);
        if (ctx.mounted) showAppSnack(ctx, 'Reading list deleted');
    }
  }

  void _openList(BuildContext ctx, LibraryReadingList l) {
    Navigator.of(ctx).push(MaterialPageRoute<void>(
      builder: (_) => Theme(
        data: libraryTheme(),
        child: StatefulBuilder(builder: (innerCtx, setInner) {
          final matches = _lists.where((x) => x.id == l.id);
          if (matches.isEmpty) return const Scaffold();
          final list = matches.first;
          return ReadingListDetailScreen(
            title: list.name,
            stories: _storiesOf(list),
            onStoryTap: (s) async {
              await _showStoryMenu(innerCtx, s);
              if (innerCtx.mounted) setInner(() {});
            },
          );
        }),
      ),
    ));
  }

  // ------------------------------------------------------ pop-up opsi story
  void _onStoryTap(BuildContext ctx, LibraryStory s) =>
      _editMode ? _toggleSelected(s.id) : _showStoryMenu(ctx, s);

  Future<void> _showStoryMenu(BuildContext ctx, LibraryStory story) async {
    final action = await showStoryOptionsDialog(ctx, story);
    if (action == null || !ctx.mounted) return;

    switch (action) {
      case StoryAction.read:
        _markRead(story.id);
        openStoryFromSearch(ctx, int.parse(story.id));
      case StoryAction.info:
        showStoryInfoSheet(ctx, story);
      case StoryAction.share:
        await Clipboard.setData(
            ClipboardData(text: 'https://www.wattpad.com/story/${story.id}'));
        if (ctx.mounted) showAppSnack(ctx, 'Story link copied');
      case StoryAction.remove:
        final removed = await _remove(story.id);
        if (ctx.mounted && removed != null) {
          showAppSnack(ctx, 'Removed from library',
              actionLabel: 'UNDO', onAction: () => _restore(removed));
        }
      case StoryAction.archive:
        await _archive(story.id);
        if (ctx.mounted) {
          showAppSnack(ctx, 'Story archived',
              actionLabel: 'UNDO', onAction: () => _unarchive(story.id));
        }
      case StoryAction.unarchive:
        await _unarchive(story.id);
        if (ctx.mounted) showAppSnack(ctx, 'Story moved to Current Reads');
      case StoryAction.addToReadingList:
        await showAddToReadingListDialog(
          ctx,
          story: story,
          getLists: () => _lists,
          onToggle: (id) => _toggleStoryInList(id, story.id),
          onCreate: (name) => _createList(name, withStoryId: story.id),
        );
      case StoryAction.addToOffline:
        await _setOffline(story.id, true);
        if (ctx.mounted) showAppSnack(ctx, 'Added to Offline list');
      case StoryAction.removeFromOffline:
        await _setOffline(story.id, false);
        if (ctx.mounted) showAppSnack(ctx, 'Removed from Offline list');
    }
  }

  Future<void> _toggleOffline(BuildContext ctx, LibraryStory s) async {
    await _setOffline(s.id, !s.isOffline);
    if (ctx.mounted) {
      showAppSnack(ctx,
          s.isOffline ? 'Removed from Offline list' : 'Added to Offline list');
    }
  }

  // ---------------------------------------------------------------- app bar
  List<Widget> _actions(BuildContext ctx) {
    switch (_tab.index) {
      case 0:
        return [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline, size: 28),
            onPressed: () => Navigator.of(ctx).push(MaterialPageRoute<void>(
              builder: (_) =>
                  Theme(data: libraryTheme(), child: const FaqScreen()),
            )),
          ),
          IconButton(
            tooltip: _editMode ? 'Done' : 'Edit',
            icon: Icon(_editMode ? Icons.check : Icons.edit_outlined, size: 28),
            onPressed: _toggleEdit,
          ),
          const SizedBox(width: 4),
        ];
      case 1:
        return [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (_) => _unarchiveAll(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Unarchive all'))
            ],
          ),
        ];
      default:
        return [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (_) async {
              final name = await showNameDialog(ctx,
                  title: 'New reading list', confirmLabel: 'Create');
              if (name != null) await _createList(name);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'new', child: Text('New reading list'))
            ],
          ),
        ];
    }
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: libraryTheme(),
      child: Builder(builder: (ctx) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            title: const Text('Library'),
            actions: _actions(ctx),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: ColoredBox(
                color: LibColors.tabBar,
                child: TabBar(
                  controller: _tab,
                  indicatorColor: LibColors.orange,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  splashFactory: NoSplash.splashFactory,
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'CURRENT READS'),
                    Tab(text: 'ARCHIVE'),
                    Tab(text: 'READING LISTS'),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    CurrentReadsTab(
                      totalCount: _currentCount,
                      offline: _offline,
                      saved: _saved,
                      sort: _sort,
                      viewMode: _viewMode,
                      editMode: _editMode,
                      selectedIds: _selected,
                      isLoading: _loading,
                      errorMessage: _error,
                      onRefresh: _load,
                      onSortTap: () async {
                        final s = await showSortSheet(ctx, _sort);
                        if (s != null) _set(() => _sort = s);
                      },
                      onViewModeTap: () => _set(() => _viewMode =
                          _viewMode == LibraryViewMode.grid
                              ? LibraryViewMode.list
                              : LibraryViewMode.grid),
                      onStoryTap: (s) => _onStoryTap(ctx, s),
                      onStoryMenu: (s) => _showStoryMenu(ctx, s),
                      onToggleOffline: (s) => _toggleOffline(ctx, s),
                      // backend: navigasi ke Wattpad Originals / Search.
                      onBrowse: () =>
                          showAppSnack(ctx, 'Browse Wattpad Originals'),
                      //backend: navigasi ke hasil pencarian tag.
                      onTopicTap: (t) => showAppSnack(ctx, 'Search #$t'),
                    ),
                    ArchiveTab(
                      stories: _archived,
                      onStoryMenu: (s) => _showStoryMenu(ctx, s),
                    ),
                    ReadingListsTab(
                      lists: _lists,
                      storiesOf: _storiesOf,
                      onOpen: (l) => _openList(ctx, l),
                      onMenu: (l, a) => _onListMenu(ctx, l, a),
                      onLikedTap: () =>
                          showAppSnack(ctx, 'Liked reading lists'),
                    ),
                  ],
                ),
              ),
              if (_editMode && _tab.index == 0)
                EditSelectionBar(
                  count: _selected.length,
                  onAddToList: () => _addSelectedToReadingList(ctx), // <-- baru
                  onArchive: _archiveSelected,
                  onRemove: _removeSelected,
                ),
            ],
          ),
        );
      }),
    );
  }
}
