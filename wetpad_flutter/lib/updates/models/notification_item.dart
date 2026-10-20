import '../utils/formatters.dart';

enum NotificationType { follow, like, comment, storyUpdate }

NotificationType _typeFrom(String s) => switch (s) {
  'follow' => NotificationType.follow,
  'like' => NotificationType.like,
  'comment' => NotificationType.comment,
  _ => NotificationType.storyUpdate,
};

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final int minutesAgo;
  final bool isRead;
  final int? storyId; // NEW: which story to open when tapped
  final int? partId; // NEW

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.minutesAgo,
    this.isRead = false,
    this.storyId,
    this.partId,
  });

  // NEW: builds an item from the JSON that Laravel sends
  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
    id: '${j['id']}',
    type: _typeFrom(j['type'] ?? ''),
    title: j['title'] ?? '',
    body: j['body'] ?? '',
    minutesAgo: DateTime.now()
        .difference(DateTime.parse(j['created_at']))
        .inMinutes,
    isRead: j['is_read'] == true,
    storyId: j['story_id'],
    partId: j['part_id'],
  );

  String get timeAgo => timeAgoLabel(minutesAgo);

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
    id: id,
    type: type,
    title: title,
    body: body,
    minutesAgo: minutesAgo,
    isRead: isRead ?? this.isRead,
    storyId: storyId,
    partId: partId,
  );
}
