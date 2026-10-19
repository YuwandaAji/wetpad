import '../utils/formatters.dart';
import 'community.dart';
import 'story.dart';

enum FeedItemType { readingListAdded, comment, newReadingList, communityPost }

class FeedItem {
  final String id;
  final Community community;
  final FeedItemType type;
  final int minutesAgo;
  final String title;
  final String? subtitle;
  final List<Story> stories;
  final int storyCount; // used by readingListAdded
  final String? targetName; // used by comment
  final String? commentText; // used by comment
  final String? postId; // used by communityPost
  final int commentCount; // used by communityPost

  const FeedItem({
    required this.id,
    required this.community,
    required this.type,
    required this.minutesAgo,
    required this.title,
    this.subtitle,
    this.stories = const [],
    this.storyCount = 0,
    this.targetName,
    this.commentText,
    this.postId,
    this.commentCount = 0,
  });

  String get timeAgo => timeAgoLabel(minutesAgo);
}
