import '../utils/formatters.dart';

enum NotificationType { follow, like, comment, storyUpdate }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final int minutesAgo;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.minutesAgo,
    this.isRead = false,
  });

  String get timeAgo => timeAgoLabel(minutesAgo);

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        type: type,
        title: title,
        body: body,
        minutesAgo: minutesAgo,
        isRead: isRead ?? this.isRead,
      );
}
