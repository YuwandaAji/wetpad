enum LibrarySort {
  recentlyRead,
  recentlyUpdated,
  recentlyAdded,
  storyTitle,
  writer
}

extension LibrarySortLabel on LibrarySort {
  String get label => switch (this) {
        LibrarySort.recentlyRead => 'Recently read',
        LibrarySort.recentlyUpdated => 'Recently updated',
        LibrarySort.recentlyAdded => 'Recently added',
        LibrarySort.storyTitle => 'Story title',
        LibrarySort.writer => 'Writer',
      };
}

enum LibraryViewMode { grid, list }

// ------------------------------------------------------------------ models
class LibraryStory {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;
  final double progress; // 0.0 - 1.0
  final bool isOffline;
  final bool isArchived;
  final DateTime lastReadAt;
  final DateTime addedAt;
  final DateTime? updatedAt; // baru: tanggal terakhir diupdate penulis

  const LibraryStory({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
    this.progress = 0,
    this.isOffline = false,
    this.isArchived = false,
    required this.lastReadAt,
    required this.addedAt,
    this.updatedAt,
  });

  LibraryStory copyWith(
          {bool? isOffline, bool? isArchived, DateTime? lastReadAt}) =>
      LibraryStory(
        id: id,
        title: title,
        author: author,
        coverUrl: coverUrl,
        description: description,
        progress: progress,
        isOffline: isOffline ?? this.isOffline,
        isArchived: isArchived ?? this.isArchived,
        lastReadAt: lastReadAt ?? this.lastReadAt,
        addedAt: addedAt,
        updatedAt: updatedAt,
      );
  factory LibraryStory.fromJson(Map<String, dynamic> j) => LibraryStory(
        id: j['id'].toString(),
        title: j['title'] as String,
        author: j['author'] as String,
        coverUrl: j['cover_url'] as String?,
        description: j['description'] as String?,
        progress: (j['progress'] as num?)?.toDouble() ?? 0,
        isOffline: j['is_offline'] as bool? ?? false,
        isArchived: j['is_archived'] as bool? ?? false,
        lastReadAt: DateTime.parse(j['last_read_at'] as String),
        addedAt: DateTime.parse(j['added_at'] as String),
        updatedAt: j['updated_at'] == null
            ? null
            : DateTime.parse(j['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'cover_url': coverUrl,
        'description': description,
        'progress': progress,
        'is_offline': isOffline,
        'is_archived': isArchived,
        'last_read_at': lastReadAt.toIso8601String(),
        'added_at': addedAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class LibraryReadingList {
  final String id;
  final String name;
  final List<String> storyIds;
  final bool isPublic;

  const LibraryReadingList({
    required this.id,
    required this.name,
    this.storyIds = const [],
    this.isPublic = true,
  });

  LibraryReadingList copyWith(
          {String? name, List<String>? storyIds, bool? isPublic}) =>
      LibraryReadingList(
        id: id,
        name: name ?? this.name,
        storyIds: storyIds ?? this.storyIds,
        isPublic: isPublic ?? this.isPublic,
      );

  factory LibraryReadingList.fromJson(Map<String, dynamic> j) =>
      LibraryReadingList(
        id: j['id'].toString(),
        name: j['name'] as String,
        storyIds:
            (j['story_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
        isPublic: j['is_public'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'story_ids': storyIds, 'is_public': isPublic};
}

// ============================================================================
// SPACE: RESTful API + DATABASE  (belum dikerjakan, sesuai permintaan)
// ============================================================================
abstract class LibraryRepository {
  Future<List<LibraryStory>> fetchStories();
  Future<List<LibraryReadingList>> fetchReadingLists();
  Future<void> saveStory(LibraryStory story); // upsert
  Future<void> deleteStory(String id);
  Future<void> saveReadingList(LibraryReadingList list); // upsert
  Future<void> deleteReadingList(String id);
}

class RemoteLibraryRepository implements LibraryRepository {
  @override
  Future<List<LibraryStory>> fetchStories() => throw UnimplementedError('TODO');
  @override
  Future<List<LibraryReadingList>> fetchReadingLists() =>
      throw UnimplementedError('TODO');
  @override
  Future<void> saveStory(LibraryStory story) =>
      throw UnimplementedError('TODO');
  @override
  Future<void> deleteStory(String id) => throw UnimplementedError('TODO');
  @override
  Future<void> saveReadingList(LibraryReadingList list) =>
      throw UnimplementedError('TODO');
  @override
  Future<void> deleteReadingList(String id) => throw UnimplementedError('TODO');
}

class MockLibraryRepository implements LibraryRepository {
  final Map<String, LibraryStory> _stories = {};
  final Map<String, LibraryReadingList> _lists = {};

  MockLibraryRepository() {
    final now = DateTime.now();
    final s1 = LibraryStory(
      id: '1001',
      title: 'Duplicity: Volume One (W by Wattpad Originals)',
      author: 'Jules Arlidge',
      coverUrl: 'lib/search/assets/covers/cover_1.jpg', // ← tambah
      description: 'Volume one of Duplicity.',
      progress: 1.0,
      lastReadAt: now.subtract(const Duration(hours: 1)),
      addedAt: now.subtract(const Duration(days: 5)),
    );
    final s2 = LibraryStory(
      id: '1002',
      title: 'MY "YES" IS A LIE (MADNESS)',
      author: 'love_story70871',
      coverUrl: 'lib/search/assets/covers/cover_2.jpg', // ← tambah
      description: 'Cerita dummy untuk tab Archive.',
      progress: 0.3,
      isArchived: true,
      lastReadAt: now.subtract(const Duration(days: 3)),
      addedAt: now.subtract(const Duration(days: 9)),
    );
    _stories[s1.id] = s1;
    _stories[s2.id] = s2;
    _lists['rl_1'] = const LibraryReadingList(
        id: 'rl_1', name: "Enjellwell's Reading List", storyIds: ['1001']);
  }

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 250));

  @override
  Future<List<LibraryStory>> fetchStories() async {
    await _delay();
    return _stories.values.toList();
  }

  @override
  Future<List<LibraryReadingList>> fetchReadingLists() async {
    await _delay();
    return _lists.values.toList();
  }

  @override
  Future<void> saveStory(LibraryStory s) async => _stories[s.id] = s;
  @override
  Future<void> deleteStory(String id) async => _stories.remove(id);
  @override
  Future<void> saveReadingList(LibraryReadingList l) async => _lists[l.id] = l;
  @override
  Future<void> deleteReadingList(String id) async => _lists.remove(id);
}
