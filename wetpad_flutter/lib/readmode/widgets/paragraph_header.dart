
import 'package:flutter/material.dart';
import '../../../core/config_api.dart';
import '../../../core/theme.dart';
import '../models/comment.dart';
import '../services/read_api.dart';
import 'reaction_picker.dart';

class ParagraphHeader extends StatefulWidget {
  final int partId, index;
  final String quote;
  const ParagraphHeader(
      {super.key, required this.partId, required this.index, required this.quote});

  @override
  State<ParagraphHeader> createState() => _ParagraphHeaderState();
}

class _ParagraphHeaderState extends State<ParagraphHeader> {
  List<Reaction> _rs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _load() async {
    try {
      final l = await ReadApi.getReactions(widget.partId, widget.index);
      if (mounted) setState(() => _rs = l);
    } catch (_) {}
  }

  Future<void> _react(int sticker) async {
    if (Session.token == null) {
      _snack('Login dulu');
      return;
    }
    try {
      final l = await ReadApi.react(widget.partId, widget.index, sticker);
      if (mounted) setState(() => _rs = l);
    } catch (e) {
      if (mounted) _snack('$e');
    }
  }

  Future<void> _pick() async {
    final s = await showReactionPicker(context);
    if (s != null && mounted) _react(s);
  }

  // 4 reaksi teratas; kalau kurang, isi dengan reaksi bawaan berjumlah 0
  List<Reaction> get _shown {
    final l = _rs.take(4).toList();
    for (final d in const [10, 1, 2, 3]) {
      if (l.length >= 4) break;
      if (!l.any((r) => r.sticker == d)) l.add(Reaction(d, 0, false));
    }
    return l;
  }

  Widget _box({required VoidCallback onTap, required Widget child, bool mine = false}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: mine ? AppColors.orange : Colors.white24,
                width: mine ? 2 : 1.2),
          ),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white24))),
        child: Text(widget.quote,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, height: 1.4)),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          _box(
              onTap: _pick,
              child: const Icon(Icons.sentiment_satisfied_outlined, size: 32)),
          for (final r in _shown) ...[
            const SizedBox(width: 12),
            _box(
              onTap: () => _react(r.sticker),
              mine: r.mine,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(kStickers[r.sticker], style: const TextStyle(fontSize: 26)),
                Text('${r.count}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ]),
      ),
    ]);
  }
}