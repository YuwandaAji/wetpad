import 'community.dart';
import 'story.dart';

/// A reading list shared by a connection. First story = big cover,
/// the next two = small stacked covers.
class ReadingList {
  final String id;
  final String title;
  final Community owner;
  final List<Story> stories;

  const ReadingList({
    required this.id,
    required this.title,
    required this.owner,
    required this.stories,
  });
}
