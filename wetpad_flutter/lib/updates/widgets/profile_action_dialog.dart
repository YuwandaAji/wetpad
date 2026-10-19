import 'package:flutter/material.dart';

import '../models/profile.dart';

Future<bool> confirmProfileActionCancellation(
  BuildContext context,
  Profile profile, {
  required bool isBlocked,
}) async {
  final titleAction = isBlocked ? 'blokir' : 'senyap';
  final confirmLabel = isBlocked ? 'BATALKAN BLOKIR' : 'BATALKAN SENYAP';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Batalkan $titleAction ${profile.name}'),
      content: Text(
        'Akun ini sekarang bisa mengikuti, mengirimkan pesan pribadi, memosting di profil, dan mengomentari cerita kamu.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('BATAL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

String profileActionCancellationMessage(
  Profile profile, {
  required bool isBlocked,
}) {
  final action = isBlocked ? 'Blokir' : 'Senyap';
  return '$action ${profile.name} telah dibatalkan.';
}
