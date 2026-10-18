import 'package:flutter/foundation.dart';

class SearchCategory {
  const SearchCategory({
    required this.id,
    required this.name,
    this.isOriginals = false,
  });

  final String id;
  final String name;
  final bool isOriginals;

  factory SearchCategory.fromJson(Map<String, dynamic> j) => SearchCategory(
        id: j['id'].toString(),
        name: j['name'] as String,
        isOriginals: j['is_originals'] as bool? ?? false,
      );
}

class SearchStory {
  const SearchStory({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    this.views = 0,
    this.parts = 0,
    this.tags = const [],
    this.categories = const [],
    this.isOriginal = false,
  });

  final String id;
  final String title;
  final String author;
  final String cover;
  final int views;
  final int parts;
  final List<String> tags;

  final List<String> categories;
  final bool isOriginal;

  factory SearchStory.fromJson(Map<String, dynamic> j) => SearchStory(
        id: j['id'].toString(),
        title: j['title'] as String,
        author: j['author'] as String,
        cover: j['cover'] as String? ?? '',
        views: j['views'] as int? ?? 0,
        parts: j['parts'] as int? ?? 0,
        tags:
            (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        categories:
            (j['categories'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        isOriginal: j['is_original'] as bool? ?? false,
      );
}

class CategoryFeed {
  const CategoryFeed({
    required this.originals,
    required this.stories,
    required this.total,
  });

  final List<SearchStory> originals;
  final List<SearchStory> stories;
  final int total;

  factory CategoryFeed.fromJson(Map<String, dynamic> j) => CategoryFeed(
        originals: (j['originals'] as List? ?? [])
            .map((e) => SearchStory.fromJson(e as Map<String, dynamic>))
            .toList(),
        stories: (j['stories'] as List? ?? [])
            .map((e) => SearchStory.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: j['total'] as int? ?? 0,
      );
}

enum StorySort { hot, newest }

@immutable
class StoryFilter {
  const StoryFilter({this.sort = StorySort.hot, this.tags = const {}});

  final StorySort sort;
  final Set<String> tags;

  bool get isDefault => sort == StorySort.hot && tags.isEmpty;

  StoryFilter copyWith({StorySort? sort, Set<String>? tags}) =>
      StoryFilter(sort: sort ?? this.sort, tags: tags ?? this.tags);

  @override
  bool operator ==(Object other) =>
      other is StoryFilter && other.sort == sort && setEquals(other.tags, tags);

  @override
  int get hashCode => Object.hash(sort, Object.hashAllUnordered(tags));
}

String formatCount(int n) {
  String trim(double v) {
    var s = v.toStringAsFixed(2);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  if (n >= 1000000) return '${trim(n / 1000000)}M';
  if (n >= 1000) return '${trim(n / 1000)}K';
  return '$n';
}
