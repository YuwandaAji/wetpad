
import 'package:flutter/material.dart';
import '../../../core/config_api.dart';
import '../../../core/format.dart';
import '../../../core/theme.dart';
import '../models/comment.dart';
import '../services/read_api.dart';

const _teal = Color(0xFF6CC3BB);
const _authorBg = Color(0xFF3A2E2B);
const _newBg = Color(0xFF1F2A2C);

class CommentsPage extends StatefulWidget {
  final int partId;
  final String partTitle;
  final int? paragraphIndex; 
  final Widget? header; 
  const CommentsPage({
    super.key,
    required this.partId,
    required this.partTitle,
    this.paragraphIndex,
    this.header,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _topCtl = TextEditingController();
  final _replyCtl = TextEditingController();
  final _replyFocus = FocusNode();

  List<Comment> _comments = [];
  final Map<int, List<Comment>> _replies = {};
  final Set<int> _expanded = {}, _newIds = {};
  Comment? _replyTo;
  bool _loading = true, _sending = false;
  int _added = 0; // jumlah komentar yang ditambahkan, dikirim balik ke ReaderPage

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _topCtl.dispose();
    _replyCtl.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _load() async {
    try {
      final l = await ReadApi.getComments(widget.partId, paragraph: widget.paragraphIndex);
      if (mounted) setState(() => _comments = l);
    } catch (e) {
      if (mounted) _snack('$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadReplies(int rootId) async {
    final l = await ReadApi.getReplies(rootId);
    if (!mounted) return;
    setState(() {
      _replies[rootId] = l;
      _expanded.add(rootId);
    });
  }

  Future<void> _toggleReplies(Comment c) async {
    if (_expanded.contains(c.id)) {
      setState(() => _expanded.remove(c.id));
      return;
    }
    try {
      await _loadReplies(c.id);
    } catch (e) {
      if (mounted) _snack('$e');
    }
  }

  Future<void> _sendTop() async {
    final t = _topCtl.text.trim();
    if (t.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final c = await ReadApi.addComment(widget.partId, t, paragraph: widget.paragraphIndex);
      if (!mounted) return;
      setState(() {
        _comments.insert(0, c);
        _newIds.add(c.id);
        _topCtl.clear();
        _added++;
      });
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) _snack('$e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startReply(Comment c) {
    // membalas balasan: awali dengan @username seperti di Wattpad
    final pre = c.parentId != null ? '@${c.username} ' : '';
    setState(() => _replyTo = c);
    _replyCtl.value = TextEditingValue(
        text: pre, selection: TextSelection.collapsed(offset: pre.length));
    WidgetsBinding.instance.addPostFrameCallback((_) => _replyFocus.requestFocus());
  }

  void _cancelReply() {
    FocusScope.of(context).unfocus();
    setState(() => _replyTo = null);
    _replyCtl.clear();
  }

  Future<void> _sendReply() async {
    final to = _replyTo;
    final t = _replyCtl.text.trim();
    if (to == null || t.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final c = await ReadApi.addComment(widget.partId, t, parentId: to.id);
      final rootId = c.parentId ?? to.id;
      _newIds.add(c.id);
      await _loadReplies(rootId);
      if (!mounted) return;
      setState(() {
        final root = _comments.firstWhere((x) => x.id == rootId);
        root.repliesCount = _replies[rootId]!.length;
        _added++;
        _replyTo = null;
      });
      _replyCtl.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) _snack('$e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _like(Comment c) async {
    if (Session.token == null) {
      _snack('Login dulu');
      return;
    }
    try {
      final r = await ReadApi.toggleLike(c.id);
      setState(() {
        c.liked = r['liked'];
        c.likesCount = r['likes_count'];
      });
    } catch (e) {
      if (mounted) _snack('$e');
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _added);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(children: [
            Row(children: [
              IconButton(
                icon: const Icon(Icons.close, size: 30),
                onPressed: () => Navigator.pop(context, _added),
              ),
              Expanded(
                child: Text(widget.partTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
            ]),
            const Divider(height: 1, color: Colors.white24),
            if (widget.header != null) widget.header!,
            if (_replyTo == null)
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, widget.header == null ? 24 : 12),
                child: _inputBox(
                    controller: _topCtl, hint: 'Tulis komentar...', onSend: _sendTop),
              ),
            if (widget.header != null)
              Row(children: const [
                SizedBox(width: 20),
                Expanded(child: Divider(color: Colors.white24)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Iklan', style: TextStyle(color: AppColors.muted))),
                Expanded(child: Divider(color: Colors.white24)),
                SizedBox(width: 20),
              ]),
            Expanded(child: _list()),
            if (_replyTo != null) _replyBar(),
          ]),
        ),
      ),
    );
  }

  Widget _list() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.orange));
    }
    if (_comments.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.forum_outlined, size: 96, color: AppColors.muted),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text('Jadilah yang pertama memberikan komentar 💬',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ]),
      );
    }
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final c in _comments) ...[
          _tile(c),
          if (_expanded.contains(c.id))
            ...(_replies[c.id] ?? []).map((r) => _tile(r, reply: true)),
          if (c.repliesCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(68, 0, 16, 12),
              child: GestureDetector(
                onTap: () => _toggleReplies(c),
                child: Text(
                  _expanded.contains(c.id)
                      ? 'Sembunyikan balasan'
                      : 'Lihat ${c.repliesCount} balasan',
                  style: const TextStyle(
                      color: _teal, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _tile(Comment c, {bool reply = false}) {
    final bg = _newIds.contains(c.id) ? _newBg : (c.isAuthor ? _authorBg : null);
    return Container(
      color: bg,
      padding: EdgeInsets.fromLTRB(reply ? 51 : 16, 12, 16, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: reply ? 16 : 20,
          backgroundColor: const Color(0xFF3A3A3A),
          backgroundImage: c.avatarUrl != null ? NetworkImage(c.avatarUrl!) : null,
          child: c.avatarUrl == null
              ? Icon(Icons.person, size: reply ? 16 : 20, color: AppColors.muted)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(c.username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (c.isAuthor) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF4A58A),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Text('Penulis',
                      style: TextStyle(
                          color: Color(0xFF3A1E12),
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            _bodyText(c.body),
            const SizedBox(height: 6),
            Row(children: [
              Text(timeAgo(c.createdAt),
                  style: const TextStyle(color: AppColors.muted, fontSize: 14)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _startReply(c),
                child: const Text('Balas',
                    style: TextStyle(
                        color: _teal, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ]),
          ]),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _like(c),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(c.liked ? Icons.favorite : Icons.favorite_border,
                  size: 28, color: c.liked ? AppColors.orange : Colors.white),
              if (c.likesCount > 0)
                Text('${c.likesCount}', style: const TextStyle(fontSize: 14)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _bodyText(String t) {
    const style = TextStyle(fontSize: 16, height: 1.4);
    final m = RegExp(r'^@\S+').firstMatch(t);
    if (m == null) return Text(t, style: style);
    return Text.rich(TextSpan(style: style, children: [
      TextSpan(text: m.group(0), style: const TextStyle(color: _teal)),
      TextSpan(text: t.substring(m.end)),
    ]));
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onSend,
    FocusNode? focus,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: highlight ? const Color(0xFF8C7AE6) : Colors.white24, width: 1.5),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focus,
            minLines: 1,
            maxLines: 4,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration.collapsed(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: _sending ? null : onSend,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF4A467A),
            child: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.lavender))
                : const Icon(Icons.send_outlined, color: AppColors.lavender),
          ),
        ),
      ]),
    );
  }

  Widget _replyBar() => Container(
        color: AppColors.bg,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text('Membalas ${_replyTo!.username}',
                    style: const TextStyle(fontSize: 15))),
            GestureDetector(
              onTap: _cancelReply,
              child: const Icon(Icons.close, size: 20, color: AppColors.muted),
            ),
          ]),
          const SizedBox(height: 8),
          _inputBox(
            controller: _replyCtl,
            focus: _replyFocus,
            hint: 'Tulis balasan...',
            highlight: true,
            onSend: _sendReply,
          ),
        ]),
      );
}