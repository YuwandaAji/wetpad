
class Comment {
  final int id;
  final int? parentId;
  final String body, username;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isAuthor;
  bool liked;
  int likesCount, repliesCount;

  Comment.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        parentId = j['parent_id'],
        body = j['body'],
        username = j['user']['username'],
        avatarUrl = j['user']['avatar_url'],
        createdAt = DateTime.parse(j['created_at']).toLocal(),
        isAuthor = j['is_author'] ?? false,
        liked = j['liked'] ?? false,
        likesCount = j['likes_count'] ?? 0,
        repliesCount = j['replies_count'] ?? 0;
}

class Reaction {
  final int sticker, count;
  final bool mine;
  const Reaction(this.sticker, this.count, this.mine);

  factory Reaction.fromJson(Map<String, dynamic> j) =>
      Reaction(j['sticker'], j['count'], j['mine'] ?? false);
}