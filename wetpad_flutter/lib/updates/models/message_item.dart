import '../utils/formatters.dart';

class MessageItem {
  final String id;
  final String sender;
  final String preview;
  final int minutesAgo;
  final bool isRead;

  const MessageItem({
    required this.id,
    required this.sender,
    required this.preview,
    required this.minutesAgo,
    this.isRead = false,
  });

  String get timeAgo => timeAgoLabel(minutesAgo);
}
