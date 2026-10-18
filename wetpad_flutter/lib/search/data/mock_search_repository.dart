import 'search_models.dart';
import 'search_repository.dart';

class MockSearchRepository implements SearchRepository {
  static const _covers = 'lib/search/assets/covers/';
  static const _originals = 'lib/search/assets/originals/';

  static const _categoryNames = [
    'Romance',
    'Fanfiction',
    'LGBTQ+',
    'Wattpad Originals',
    'Werewolf',
    'New Adult',
    'Fantasy',
    'Short Story',
    'Teen Fiction',
    'Historical Fiction',
    'Paranormal',
    "Editor's Picks",
    'Humor',
    'Horror',
    'Contemporary Lit',
    'Diverse Lit',
    'Mystery',
    'Thriller',
    'Science Fiction',
    'The Wattys',
    'Adventure',
    'Non-Fiction',
    'Poetry',
  ];
  static String _slug(String n) =>
      n.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

  static final List<String> _genreIds = _categoryNames.map(_slug).toList();
  static const _tagPool = [
    'slowburn',
    'love',
    'arrangedmarriage',
    'billionaire',
    'desi',
    'india',
    'indian',
    'texttospeech',
    'possessive',
    'ceo',
    'lovestory',
    'marriage',
    'wattpadindia',
    'desiromance',
    'secondchance',
    'forcedmarriage',
    'enemiestolovers',
    'indianromance',
    'family',
  ];

  static const _authors = [
    'luna_writes',
    'kaelvance',
    'mirasolstories',
    'dearestnova',
    'ravenink',
    'sunnyscribbles',
    'velvetpages',
  ];

  static const _titles = [
    'Crown of Ashes',
    "The Billionaire's Contract Bride",
    'Between Two Monsoons',
    'Whispers in the Rain',
    'Marked by the Mafia King',
    'Letters I Never Sent',
    'The Last Summer in Kyoto',
    'Bound by Midnight Vows',
    'My Husband, My Enemy',
    'Silver Hearts, Golden Chains',
    'Perfectly Imperfect',
    "The CEO's Secret Heir",
    'Ink and Embers',
    'Where the Lanterns Fall',
    'A Second Chance at Forever',
    'Beneath the Velvet Sky',
    'Sold to the Devil',
    "The Cartographer's Daughter",
    'Heartbeat Away',
    'Until the Stars Burn Out',
  ];

  /// 20 story. Cover dipakai ulang: cover_1 ... cover_8.
  static final List<SearchStory> _stories = List.generate(_titles.length, (i) {
    final tags = <String>{
      _tagPool[i % _tagPool.length],
      _tagPool[(i * 3 + 1) % _tagPool.length],
      _tagPool[(i * 5 + 2) % _tagPool.length],
      _tagPool[(i * 7 + 3) % _tagPool.length],
    }.toList();
    return SearchStory(
      id: 's${i + 1}',
      title: _titles[i],
      author: _authors[i % _authors.length],
      cover: '${_covers}cover_${i % 8 + 1}.jpg',
      views: 60000000 ~/ (i + 1),
      parts: 20 + (i * 37) % 110,
      tags: tags,
      categories: {
        _genreIds[(i * 2) % _genreIds.length],
        _genreIds[(i * 2 + 1) % _genreIds.length],
        if (i % 2 == 0) 'romance',
      }.toList(),
    );
  });

  static const _originalStories = <SearchStory>[
    SearchStory(
      id: 'o1',
      title: 'Strip for the Devil',
      author: 'demo_author',
      cover: '${_originals}original_1.jpg',
      isOriginal: true,
    ),
    SearchStory(
      id: 'o2',
      title: 'Overdrive',
      author: 'demo_author',
      cover: '${_originals}original_2.jpg',
      isOriginal: true,
    ),
    SearchStory(
      id: 'o3',
      title: 'No Second Chances',
      author: 'demo_author',
      cover: '${_originals}original_3.jpg',
      isOriginal: true,
    ),
    SearchStory(
      id: 'o4',
      title: 'Love for Sale',
      author: 'demo_author',
      cover: '${_originals}original_4.jpg',
      isOriginal: true,
    ),
  ];

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<SearchCategory>> fetchCategories() async {
    await _latency();
    return [
      for (final n in _categoryNames)
        SearchCategory(
          id: n.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
          name: n,
          isOriginals: n == 'Wattpad Originals',
        ),
    ];
  }

  @override
  Future<CategoryFeed> fetchCategoryFeed(
    String categoryId, {
    StoryFilter filter = const StoryFilter(),
  }) async {
    await _latency();

    var list =
        _stories.where((s) => s.categories.contains(categoryId)).toList();

    list = list.where((s) => filter.tags.every(s.tags.contains)).toList();

    if (filter.sort == StorySort.hot) {
      list.sort(
          (a, b) => b.views.compareTo(a.views)); // reader terbanyak = rank 1
    } else {
      list = list.reversed.toList(); // dummy belum punya tanggal rilis
    }

    return CategoryFeed(
      originals: _originalStories,
      stories: list,
      total: list.length,
    );
  }

  @override
  Future<List<String>> fetchFilterTags(String categoryId) async {
    await _latency();
    final tags = <String>{
      for (final s in _stories)
        if (s.categories.contains(categoryId)) ...s.tags,
    };
    return tags.toList();
  }

  @override
  Future<List<String>> fetchTrendingKeywords() async {
    await _latency();
    return const [
      'the lament of autumn',
      'my beloved fool',
      'tokyo revengers',
      'yuno',
      'early spring',
      'harry potter',
      'the 100',
    ];
  }

  @override
  Future<List<SearchStory>> searchStories(String query) async {
    await _latency();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _stories
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.author.toLowerCase().contains(q) ||
            s.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }
}
