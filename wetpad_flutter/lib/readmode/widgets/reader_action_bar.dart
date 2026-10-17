// lib/features/readmode/widgets/reader_action_bar.dart
import 'package:flutter/material.dart';
import '../../../core/config_api.dart';
import '../models/part.dart';
import '../services/read_api.dart';

class ReaderActionBar extends StatefulWidget {
  final Part part;
  const ReaderActionBar({super.key, required this.part});

  @override
  State<ReaderActionBar> createState() => _ReaderActionBarState();
}

class _ReaderActionBarState extends State<ReaderActionBar> {
  late bool _voted = widget.part.voted;
  late int _votes = widget.part.votes;

  Future<void> _vote() async {
    if (Session.token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login dulu')));
      return;
    }
    try {
      final r = await ReadApi.toggleVote(widget.part.id);
      setState(() {
        _voted = r['voted'];
        _votes = r['votes'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _vote,
              icon: Icon(_voted ? Icons.star : Icons.star_border,
                  color: _voted ? const Color(0xFFFF6122) : Colors.grey),
              label: Text('$_votes'),
            ),
            TextButton.icon(
              onPressed: () {}, // nanti: CommentSheet
              icon: const Icon(Icons.mode_comment_outlined, color: Colors.grey),
              label: Text('${widget.part.commentsCount}'),
            ),
            IconButton(
              onPressed: () {}, // nanti: share
              icon: const Icon(Icons.share_outlined, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}