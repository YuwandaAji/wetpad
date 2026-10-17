// lib/features/readmode/widgets/reaction_picker.dart
import 'package:flutter/material.dart';

const kStickers = [
  '😍', '😂', '😭', '😱', '🔥', '👏', '💔', '🥺',
  '😡', '🤯', '❤️', '👍', '🎉', '😴', '🤔', '😎',
  '🙈', '💀', '🥰', '😅', '🤣', '😢', '😤', '😘',
];

/// Mengembalikan nomor stiker yang dipilih (atau null kalau ditutup).
Future<int?> showReactionPicker(BuildContext context) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF262626),
    shape: const RoundedRectangleBorder(),
    constraints:
        BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.68),
    builder: (ctx) => Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2)),
            child: const Icon(Icons.question_mark, size: 22),
          ),
          const SizedBox(width: 16),
          const Expanded(
              child: Text('Bagaimana perasaanmu terhadap bab ini?',
                  style: TextStyle(fontSize: 17))),
          IconButton(
              icon: const Icon(Icons.close, size: 32),
              onPressed: () => Navigator.pop(ctx)),
        ]),
      ),
      const Divider(height: 1, color: Colors.white12),
      Expanded(
        child: GridView.count(
          crossAxisCount: 4,
          padding: const EdgeInsets.all(12),
          children: [
            for (var i = 0; i < kStickers.length; i++)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pop(ctx, i),
                child: Center(
                    child: Text(kStickers[i], style: const TextStyle(fontSize: 44))),
              ),
          ],
        ),
      ),
    ]),
  );
}