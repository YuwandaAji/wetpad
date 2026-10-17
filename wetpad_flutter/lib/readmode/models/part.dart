
class Part {
  final int id, storyId, partNumber, votes, commentsCount, reads;
  final int? prevId, nextId;
  final String title, content, storyTitle, author;
  final String? coverUrl;
  final bool voted;
  final Map<int, int> paragraphComments; // indeks paragraf -> jumlah komentar

  Part.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        storyId = j['story_id'],
        partNumber = j['part_number'],
        title = j['title'],
        content = j['content'],
        storyTitle = j['story_title'] ?? '',
        author = j['author'] ?? '-',
        coverUrl = j['cover_url'],
        reads = j['reads'] ?? 0,
        prevId = j['prev_id'],
        nextId = j['next_id'],
        votes = j['votes'] ?? 0,
        commentsCount = j['comments_count'] ?? 0,
        voted = j['voted'] ?? false,
        paragraphComments = {
          for (final e in ((j['paragraph_comments'] as List?) ?? []))
            e['index'] as int: e['count'] as int,
        };
}