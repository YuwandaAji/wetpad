import 'package:flutter/material.dart';

import '../data/profile_action_store.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import 'mute_duration_picker.dart';
import 'post_composer.dart';

/// Kartu abu-abu yang menampilkan pengirim dan isi postingan.
class PostTile extends StatefulWidget {
  final Post post;
  final String authorId;
  final bool isMine;
  final ValueChanged<String> onReply;
  final VoidCallback onDelete;

  const PostTile({
    super.key,
    required this.post,
    required this.authorId,
    required this.isMine,
    required this.onReply,
    required this.onDelete,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  bool _showReplyBox = false;
  bool _showReplies = false;

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'report':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Laporkan pesan'),
            content: const Text(
              'Apakah Anda ingin melaporkan pesan ini kepada tim Wattpad?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Laporkan'),
              ),
            ],
          ),
        );
        if (confirmed == true && mounted) {
          ProfileActionStore.instance.reportPost(widget.post.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesan berhasil dilaporkan.')),
          );
        }
      case 'reply':
        setState(() => _showReplyBox = true);
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus pesan?'),
            content: const Text('Pesan ini akan dihapus dari percakapan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
        if (confirmed == true && mounted) {
          widget.onDelete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesan berhasil dihapus.')),
          );
        }
      case 'mute':
        final duration = await showMuteDurationPicker(context);
        if (duration != null && mounted) {
          ProfileActionStore.instance.mute(widget.authorId, duration);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesan disenyapkan sementara.')),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tabBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniAvatar(
                name: post.authorName,
                color: post.authorColor,
                radius: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: post.authorName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: ' memposting pesan'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opsi pesan',
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  if (widget.isMine)
                    const PopupMenuItem(value: 'delete', child: Text('Hapus'))
                  else ...[
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Laporkan pesan'),
                    ),
                    const PopupMenuItem(
                      value: 'mute',
                      child: Text('Senyapkan sementara'),
                    ),
                  ],
                  const PopupMenuItem(value: 'reply', child: Text('Balas')),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFDADADA)),
          ),
          Text(
            post.text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => _showReplyBox = !_showReplyBox),
            child: const Text(
              'Balas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (_showReplyBox)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: PostComposer(
                hint: 'Balas ${post.authorName}…',
                buttonLabel: 'Balas',
                fillColor: Colors.white,
                autofocus: true,
                onSubmit: (text) {
                  widget.onReply(text);
                  setState(() {
                    _showReplyBox = false;
                    _showReplies = true;
                  });
                },
              ),
            ),
          if (post.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InkWell(
                onTap: () => setState(() => _showReplies = !_showReplies),
                child: Text(
                  _showReplies
                      ? 'Sembunyikan balasan'
                      : 'Lihat ${post.replies.length} balasan',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.link,
                  ),
                ),
              ),
            ),
          if (_showReplies)
            for (final r in post.replies)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MiniAvatar(
                      name: r.authorName,
                      color: r.authorColor,
                      radius: 14,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  r.authorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                r.timeAgo,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.text,
                            style: const TextStyle(fontSize: 14, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double radius;
  const _MiniAvatar({
    required this.name,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}
