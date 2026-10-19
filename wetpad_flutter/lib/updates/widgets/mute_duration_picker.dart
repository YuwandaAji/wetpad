import 'package:flutter/material.dart';

Future<Duration?> showMuteDurationPicker(BuildContext context) {
  return showModalBottomSheet<Duration>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Senyapkan sementara'),
            subtitle: Text('Pilih berapa lama ingin disenyapkan'),
          ),
          ListTile(
            title: const Text('1 jam'),
            onTap: () => Navigator.pop(context, const Duration(hours: 1)),
          ),
          ListTile(
            title: const Text('8 jam'),
            onTap: () => Navigator.pop(context, const Duration(hours: 8)),
          ),
          ListTile(
            title: const Text('1 minggu'),
            onTap: () => Navigator.pop(context, const Duration(days: 7)),
          ),
        ],
      ),
    ),
  );
}
