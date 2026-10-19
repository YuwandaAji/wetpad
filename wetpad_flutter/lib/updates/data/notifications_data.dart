import '../models/notification_item.dart';

class NotificationsData {
  /// Set to an empty list to preview the empty state.
  static const items = <NotificationItem>[
    NotificationItem(
      id: 'n1',
      type: NotificationType.storyUpdate,
      title: 'Midnight Letters',
      body: 'PaperHearts memperbarui cerita dengan Bab 28.',
      minutesAgo: 25,
    ),
    NotificationItem(
      id: 'n2',
      type: NotificationType.follow,
      title: 'NightOwl mulai mengikuti kamu',
      body: 'Lihat profilnya dan ikuti balik.',
      minutesAgo: 140,
    ),
    NotificationItem(
      id: 'n3',
      type: NotificationType.like,
      title: 'EmberWrites menyukai komentarmu',
      body: '"Plot twist di bab terakhir benar-benar gila!"',
      minutesAgo: 600,
      isRead: true,
    ),
    NotificationItem(
      id: 'n4',
      type: NotificationType.comment,
      title: 'RavenQuill membalas komentarmu',
      body: 'Terima kasih sudah membaca, bab baru segera hadir!',
      minutesAgo: 2900,
      isRead: true,
    ),
  ];
}
