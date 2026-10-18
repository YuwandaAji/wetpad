
class Story {
  final int id, partsCount, readsTotal, votesTotal;
  final String title, status;
  final String? description, coverUrl, genre, authorName, authorAvatar;
  final DateTime? lastPublished;
  final List<String> tags;

  Story.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        title = j['title'],
        description = j['description'],
        coverUrl = j['cover_url'],
        genre = j['genre'],
        status = j['status'] ?? 'ongoing',
        tags = List<String>.from(j['tags'] ?? []),
        authorName = j['author']?['username'],
        authorAvatar = j['author']?['avatar_url'],
        lastPublished = j['last_published'] == null
            ? null
            : DateTime.tryParse(j['last_published'])?.toLocal(),
        partsCount = j['parts_count'] ?? 0,
        readsTotal = j['reads_total'] ?? 0,
        votesTotal = j['votes_total'] ?? 0;
}

class PartItem {
  final int id, partNumber, readsCount;
  final String title;
  final DateTime? createdAt;

  PartItem.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        partNumber = j['part_number'],
        title = j['title'],
        readsCount = j['reads_count'] ?? 0,
        createdAt = DateTime.tryParse(j['created_at'] ?? '')?.toLocal();
}

class StoryMini {
  final int id, partsCount;
  final String title, status;
  final String? coverUrl, description;

  StoryMini.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        title = j['title'],
        coverUrl = j['cover_url'],
        description = j['description'],
        status = j['status'] ?? 'ongoing',
        partsCount = j['parts_count'] ?? 0;
}