import 'dart:async';

import 'package:flutter/material.dart';

import '../data/search_models.dart';
import '../data/search_repository.dart';
import '../widgets/category_header.dart';
import '../widgets/originals_carousel.dart';
import '../widgets/ranked_story_tile.dart';
import '../widgets/search_field.dart';
import '../widgets/search_style.dart';
import '../widgets/stories_header.dart';
import '../widgets/trending_list.dart';
import 'filter_screen.dart';

/// Tab "SEARCH" (bottom nav index 1).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.repository, this.onStoryTap});

  final SearchRepository repository;
  final void Function(SearchStory)? onStoryTap;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  int _searchToken = 0;

  // browse
  List<SearchCategory> _categories = [];
  int _selected = 0;
  CategoryFeed? _feed;
  bool _feedLoading = true;
  Object? _feedError;
  bool _expanded = false;
  StoryFilter _filter = const StoryFilter();

  // search
  List<String> _trending = [];
  List<SearchStory> _results = [];
  bool _searching = false;

  bool get _searchMode => _focus.hasFocus || _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _boot();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- loading
  Future<void> _boot() async {
    try {
      final cats = await widget.repository.fetchCategories();
      if (!mounted) return;
      setState(() => _categories = cats);
      _loadTrending();
      await _loadFeed();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _feedError = e;
        _feedLoading = false;
      });
    }
  }

  Future<void> _loadTrending() async {
    try {
      final t = await widget.repository.fetchTrendingKeywords();
      if (mounted) setState(() => _trending = t);
    } catch (_) {
      // Trending opsional, abaikan error.
    }
  }

  Future<void> _loadFeed({bool silent = false}) async {
    if (_categories.isEmpty) return;
    final id = _categories[_selected].id;
    if (!silent) {
      setState(() {
        _feedLoading = true;
        _feedError = null;
      });
    }
    try {
      final feed =
          await widget.repository.fetchCategoryFeed(id, filter: _filter);
      if (!mounted || _categories[_selected].id != id) return;
      setState(() {
        _feed = feed;
        _feedLoading = false;
        _feedError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _feedError = e;
        _feedLoading = false;
      });
    }
  }

  // ----------------------------------------------------------------- search
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.isEmpty) {
      _searchToken++;
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(q));
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.isNotEmpty) {
      setState(() => _searching = true);
      _runSearch(q);
    }
  }

  Future<void> _runSearch(String q) async {
    final token = ++_searchToken;
    try {
      final res = await widget.repository.searchStories(q);
      if (!mounted || token != _searchToken) return; // hasil basi
      setState(() {
        _results = res;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || token != _searchToken) return;
      setState(() {
        _results = [];
        _searching = false;
      });
    }
  }

  void _onTrendingTap(String keyword) {
    _controller.text = keyword;
    _controller.selection = TextSelection.collapsed(offset: keyword.length);
    _focus.unfocus();
    setState(() => _searching = true);
    _runSearch(keyword);
  }

  void _cancelSearch() {
    _debounce?.cancel();
    _searchToken++;
    _controller.clear();
    _focus.unfocus();
    setState(() {
      _results = [];
      _searching = false;
    });
  }

  // ----------------------------------------------------------------- browse
  void _selectCategory(int i) {
    if (i == _selected && !_expanded) return;
    setState(() {
      _selected = i;
      _expanded = false;
      _filter = const StoryFilter(); // tag berbeda tiap kategori
    });
    _loadFeed();
  }

  void _openStory(SearchStory s) {
    if (widget.onStoryTap != null) {
      widget.onStoryTap!(s);
    } else {
      // TODO: Navigator.push ke halaman detail story.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Open "${s.title}"')));
    }
  }

  Future<void> _openFilter() async {
    if (_categories.isEmpty) return;
    final before = _filter;

    var tags = <String>[];
    try {
      tags = await widget.repository.fetchFilterTags(_categories[_selected].id);
    } catch (_) {
      // Tanpa tag pun layar filter tetap bisa dipakai untuk Sort.
    }
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FilterScreen(
          initial: _filter,
          availableTags: tags,
          onChanged: (f) => _filter = f,
        ),
      ),
    );
    if (!mounted) return;

    if (_filter != before) {
      setState(() {}); // update warna ikon Filter
      _loadFeed();
    }
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    return Material(
      color: SearchColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: SearchField(
                      controller: _controller,
                      focusNode: _focus,
                      onChanged: _onQueryChanged,
                      onSubmitted: _onSubmitted,
                    ),
                  ),
                  if (_searchMode)
                    TextButton(
                      onPressed: _cancelSearch,
                      child: Text('Cancel',
                          style: SearchText.button.copyWith(fontSize: 14)),
                    ),
                ],
              ),
            ),
            Expanded(child: _searchMode ? _searchBody() : _browseBody()),
          ],
        ),
      ),
    );
  }

  // ---- search body
  Widget _searchBody() {
    final q = _controller.text.trim();
    if (q.isEmpty) {
      return TrendingList(keywords: _trending, onTap: _onTrendingTap);
    }
    if (_searching) {
      return const Center(
          child: CircularProgressIndicator(color: SearchColors.accent));
    }
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('No stories found for "$q"',
              textAlign: TextAlign.center, style: SearchText.label),
        ),
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _results.length,
      itemBuilder: (_, i) => RankedStoryTile(
        story: _results[i],
        onTap: () => _openStory(_results[i]),
      ),
    );
  }

  // ---- browse body
  Widget _browseBody() {
    if (_categories.isEmpty) {
      return _feedError != null
          ? _errorView()
          : const Center(
              child: CircularProgressIndicator(color: SearchColors.accent));
    }
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: CategoryHeader.collapsedHeight),
            Expanded(child: _feedView()),
          ],
        ),
        if (_expanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = false),
              child: const ColoredBox(color: Colors.black54),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: CategoryHeader(
            categories: _categories,
            selectedIndex: _selected,
            expanded: _expanded,
            onSelect: _selectCategory,
            onToggle: () => setState(() => _expanded = !_expanded),
          ),
        ),
      ],
    );
  }

  Widget _feedView() {
    if (_feedLoading) {
      return const Center(
          child: CircularProgressIndicator(color: SearchColors.accent));
    }
    final feed = _feed;
    if (_feedError != null || feed == null) return _errorView();

    return RefreshIndicator(
      color: SearchColors.accent,
      onRefresh: () => _loadFeed(silent: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (feed.originals.isNotEmpty)
            SliverToBoxAdapter(
              child: OriginalsCarousel(
                title: 'Terpopuler di Wetpad',
                stories: feed.originals,
                onTap: _openStory,
              ),
            ),
          SliverToBoxAdapter(
            child: StoriesHeader(
              total: feed.total,
              onFilter: _openFilter,
              filterActive: !_filter.isDefault,
            ),
          ),
          if (feed.stories.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(
                  child: Text('No stories match these filters.',
                      style: SearchText.label),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => RankedStoryTile(
                  story: feed.stories[i],
                  rank: i + 1,
                  onTap: () => _openStory(feed.stories[i]),
                ),
                childCount: feed.stories.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Something went wrong.', style: SearchText.label),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _categories.isEmpty ? _boot : _loadFeed,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
