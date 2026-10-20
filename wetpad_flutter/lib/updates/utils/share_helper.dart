import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

String profileShareLink(String username) =>
    'https://wetpad.app/user/${Uri.encodeComponent(username)}';

String storyShareLink(String storyId) =>
    'https://wetpad.app/story/${Uri.encodeComponent(storyId)}';

/// Sama persis dengan tombol "Bagikan" di mode baca:
/// buka share sheet; kalau tidak tersedia, salin ke clipboard.
Future<void> shareContent(
  BuildContext context, {
  required String text,
  required String subject,
  String copiedMessage = 'Tautan disalin',
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final r = await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
    if (r.status == ShareResultStatus.unavailable) throw 'unavailable';
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(copiedMessage)));
  }
}

Future<void> inviteFriends(BuildContext context, String username) {
  return shareContent(
    context,
    text: 'Ayo gabung di Wetpad dan ikuti aku!\n${profileShareLink(username)}',
    subject: 'Undang teman ke Wetpad',
    copiedMessage: 'Tautan profil disalin. Bagikan kepada temanmu!',
  );
}