// lib/features/readmode/pages/reader_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/config_api.dart';
import '../../../core/format.dart';
import '../../../core/theme.dart';
import '../models/part.dart';
import '../models/story.dart';
import '../services/read_api.dart';
import '../widgets/paragraph_header.dart';
import '../widgets/reaction_picker.dart';
import 'comment_page.dart';
import 'report_page.dart';

/// Pengaturan baca, disimpan statis supaya tetap sama saat pindah bab.
class ReaderPrefs {
  static bool follow = true;
  static String theme = 'dark'; // light | dark | sepia
  static double fontSize = 20;
  static bool serif = true;
}

class _Palette {
  final Color bg, fg, bar, barFg, muted, bottom;
  const _Palette(this.bg, this.fg, this.bar, this.barFg, this.muted, this.bottom);

  static const light = _Palette(Colors.white, Color(0xFF222222), Colors.white,
      Colors.black87, Color(0xFF777777), Color(0xFFF2F2F2));
  static const dark = _Palette(Color(0xFF121212), Color(0xFFE6E6E6), Color(0xFF121212),
      Colors.white, Color(0xFFA0A0A0), Color(0xFF2B2B2B));
  static const sepia = _Palette(Color(0xFFFBF0D9), Color(0xFF3B2F1E), Color(0xFFFBF0D9),
      Color(0xFF3B2F1E), Color(0xFF8A7A62), Color(0xFFF0E2C0));

  static _Palette of(String t) => t == 'light' ? light : (t == 'sepia' ? sepia : dark);
}

class ReaderPage extends StatefulWidget {
  final int partId;
  const ReaderPage({super.key, required this.partId});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scroll = ScrollController();
  final _progress = ValueNotifier<double>(0);

  Part? _part;
  List<PartItem> _parts = [];
  String? _error;
  bool _bars = true, _settings = false, _inLibrary = false, _voted = false;
  int _votes = 0, _extraComments = 0;

  // paragraf + seleksi
  List<String> _paras = [];
  final List<TextEditingController> _ctls = [];
  Map<int, int> _paraCounts = {};
  int? _selPara;
  String _selText = '';

  _Palette get _pal => _Palette.of(ReaderPrefs.follow ? 'dark' : ReaderPrefs.theme);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(widget.partId);
  }

  @override
  void dispose() {
    for (final c in _ctls) {
      c.dispose();
    }
    _scroll.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    _progress.value = max <= 0 ? 0 : (_scroll.offset / max).clamp(0.0, 1.0);
  }

  Future<void> _load(int id) async {
    setState(() {
      _part = null;
      _error = null;
      _settings = false;
      _extraComments = 0;
      _selPara = null;
      _selText = '';
    });
    try {
      final p = await ReadApi.getPart(id);
      if (!mounted) return;
      _setParagraphs(p.content);
      setState(() {
        _part = p;
        _voted = p.voted;
        _votes = p.votes;
        _paraCounts = Map.of(p.paragraphComments);
      });
      _progress.value = 0;
      ReadApi.saveProgress(p.storyId, p.id);
      if (_parts.isEmpty) {
        ReadApi.getParts(p.storyId).then((l) {
          if (mounted) setState(() => _parts = l);
        }).catchError((_) {});
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  // ---------- paragraf & seleksi ----------
  void _setParagraphs(String content) {
    final old = List<TextEditingController>.of(_ctls);
    _ctls.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in old) {
        c.dispose();
      }
    });
    _paras = content
        .split(RegExp(r'\n+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    for (var i = 0; i < _paras.length; i++) {
      final c = TextEditingController(text: _paras[i]);
      c.addListener(() => _onParaChanged(i));
      _ctls.add(c);
    }
  }

  void _onParaChanged(int i) {
    if (i >= _ctls.length) return;
    final c = _ctls[i];
    final s = c.selection;
    if (s.isValid && !s.isCollapsed) {
      final t = s.textInside(c.text).trim();
      if (_selPara != i || _selText != t) {
        setState(() {
          _selPara = i;
          _selText = t;
        });
      }
    } else if (_selPara != null) {
      _clearSelection(); // ketuk di tempat lain = batal seleksi
    }
  }

  void _clearSelection() {
    final i = _selPara;
    setState(() {
      _selPara = null;
      _selText = '';
    });
    if (i != null && i < _ctls.length) {
      _ctls[i].selection = const TextSelection.collapsed(offset: 0);
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _openParagraph(int i) async {
    final p = _part!;
    final added = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CommentsPage(
          partId: p.id,
          partTitle: p.title,
          paragraphIndex: i,
          header: ParagraphHeader(partId: p.id, index: i, quote: _paras[i]),
        ),
      ),
    );
    if (added != null && added > 0 && mounted) {
      setState(() {
        _paraCounts[i] = (_paraCounts[i] ?? 0) + added;
        _extraComments += added;
      });
    }
  }

  Future<void> _openSelectedParagraph() async {
    final i = _selPara;
    if (i == null) return;
    _clearSelection();
    await _openParagraph(i);
  }

  Future<void> _pickReaction() async {
    final i = _selPara;
    final p = _part;
    if (i == null || p == null) return;
    if (Session.token == null) {
      _snack('Login dulu');
      return;
    }
    final s = await showReactionPicker(context);
    if (s == null || !mounted) return;
    try {
      await ReadApi.react(p.id, i, s);
      if (mounted) _snack('Reaksi terkirim');
    } catch (e) {
      if (mounted) _snack('$e');
    }
    if (mounted) _clearSelection();
  }

  // ---------- aksi ----------
  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _vote() async {
    if (Session.token == null) {
      _snack('Login dulu');
      return;
    }
    try {
      final r = await ReadApi.toggleVote(_part!.id);
      setState(() {
        _voted = r['voted'];
        _votes = r['votes'];
      });
    } catch (e) {
      if (mounted) _snack('$e');
    }
  }

  Future<void> _shareText(String text, String subject) async {
    try {
      final r = await SharePlus.instance.share(ShareParams(text: text, subject: subject));
      if (r.status == ShareResultStatus.unavailable) throw 'unavailable';
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) _snack('Tautan disalin');
    }
  }

  Future<void> _share() {
    final p = _part!;
    return _shareText(
        '${p.title} - ${p.storyTitle}\nhttps://wetpad.app/part/${p.id}', p.title);
  }

  Future<void> _shareQuote() {
    final p = _part!;
    return _shareText(
        '"$_selText"\n- ${p.storyTitle}, ${p.title}\nhttps://wetpad.app/part/${p.id}',
        p.title);
  }

  Future<void> _addToLibrary() async {
    try {
      await ReadApi.addToLibrary(_part!.storyId);
      if (!mounted) return;
      setState(() => _inLibrary = true);
      _snack('Ditambahkan ke perpustakaan');
    } catch (e) {
      if (mounted) _snack('$e');
    }
  }

  Future<void> _openComments() async {
    final p = _part!;
    final added = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CommentsPage(partId: p.id, partTitle: p.title),
      ),
    );
    if (added != null && added > 0 && mounted) {
      setState(() => _extraComments += added);
    }
  }

  void _showActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
            child: Row(children: [
              const Expanded(
                  child: Text('Tindakan',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              IconButton(
                  icon: const Icon(Icons.close, size: 30),
                  onPressed: () => Navigator.pop(ctx)),
            ]),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined, size: 28),
            title: const Text('Laporkan', style: TextStyle(fontSize: 20)),
            onTap: () async {
              Navigator.pop(ctx);
              final p = _part!;
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) =>
                      ReportPage(storyId: p.storyId, reasonPrefix: 'Bab #${p.id} > '),
                ),
              );
              if (ok == true && mounted) _snack('Laporan terkirim. Terima kasih!');
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  TextStyle _font(double size, {Color? color, FontWeight? weight, double? height}) =>
      ReaderPrefs.serif
          ? GoogleFonts.notoSerif(
              fontSize: size, color: color, fontWeight: weight, height: height)
          : GoogleFonts.notoSans(
              fontSize: size, color: color, fontWeight: weight, height: height);

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final pal = _pal;
    final p = _part;
    final selecting = _selPara != null;
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: pal.bg,
      appBar: selecting ? _selectionBar(pal) : (_bars ? _appBar(p, pal) : null),
      endDrawer: p == null ? null : _drawer(p),
      body: _body(pal),
      bottomNavigationBar:
          (_bars && !selecting && p != null) ? _bottomBar(p, pal) : null,
    );
  }

  PreferredSizeWidget _appBar(Part? p, _Palette pal) => AppBar(
        backgroundColor: pal.bar,
        foregroundColor: pal.barFg,
        elevation: 0,
        titleSpacing: 0,
        title: Text(p?.storyTitle ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.cloud_download_outlined, size: 28),
              onPressed: () {}),
          const SizedBox(width: 12),
          IconButton(
            icon: Text('Aa',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w500, color: pal.barFg)),
            onPressed: () => setState(() => _settings = !_settings),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted, size: 30),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(width: 12),
        ],
      );

  // bar atas saat teks dipilih
  // bar atas saat teks dipilih
// bar atas saat teks dipilih
PreferredSizeWidget _selectionBar(_Palette pal) => PreferredSize(
        preferredSize: const Size.fromHeight(59),
        child: Container(
          color: pal.bar,
          child: SafeArea(
            bottom: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                height: 56,
                child: Row(children: [
                  IconButton(
                    icon: Icon(Icons.close, size: 30, color: pal.muted),
                    onPressed: _clearSelection,
                  ),
                  const Spacer(),
                  _circleIcon(FontAwesomeIcons.facebookF, const Color(0xFF3B5998), _shareQuote),
                  _circleIcon(FontAwesomeIcons.xTwitter, const Color(0xFF1DA1F2), _shareQuote),
                  _barIcon(Icons.chat_bubble_outline, pal.barFg, _openSelectedParagraph),
                  _barIcon(Icons.add_reaction_outlined, pal.barFg, _pickReaction),
                  const SizedBox(width: 8),
                ]),
              ),
              ValueListenableBuilder<double>(
                valueListenable: _progress,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 3,
                  color: AppColors.orange,
                  backgroundColor: Colors.white24,
                ),
              ),
            ]),
          ),
        ),
      );

  Widget _circleIcon(FaIconData i, Color bg, VoidCallback onTap) => InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Center(child: FaIcon(i, color: Colors.white, size: 15)),
            ),
          ),
        ),
      );

  Widget _barIcon(IconData i, Color c, VoidCallback onTap) => InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: Icon(i, size: 28, color: c)),
        ),
      );

  Widget _body(_Palette pal) {
    final p = _part;
    if (_error != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Gagal memuat: $_error',
                  textAlign: TextAlign.center, style: TextStyle(color: pal.fg))));
    }
    if (p == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.orange));
    }

    final content = GestureDetector(
      onTap: () => setState(() {
        _bars = !_bars;
        _settings = false;
      }),
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.only(bottom: 160),
        children: [
          _banner(p),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Text(p.title,
                textAlign: TextAlign.center,
                style: _font(26, color: pal.fg, height: 1.3)),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _stat(Icons.remove_red_eye_outlined, fmtCount(p.reads), pal),
            const SizedBox(width: 24),
            _stat(_voted ? Icons.star : Icons.star_border, fmtCount(_votes), pal),
            const SizedBox(width: 24),
            _stat(Icons.chat_bubble_outline, '${p.commentsCount + _extraComments}', pal),
          ]),
          const SizedBox(height: 32),
          for (var i = 0; i < _paras.length; i++) _paragraph(i, pal),
        ],
      ),
    );

    return TextSelectionTheme(
      data: const TextSelectionThemeData(
        selectionColor: Color(0x8026A69A),
        selectionHandleColor: Color(0xFF26A69A),
      ),
      child: Stack(children: [
        content,
        if (_settings) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _settings = false),
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: _settingsPanel()),
        ],
      ]),
    );
  }

  Widget _paragraph(int i, _Palette pal) {
    final count = _paraCounts[i] ?? 0;
    final selected = _selPara == i;
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 48, 20),
        child: TextField(
          controller: _ctls[i],
          readOnly: true,
          showCursor: false,
          maxLines: null,
          style: _font(ReaderPrefs.fontSize, color: pal.fg, height: 1.6),
          decoration: const InputDecoration.collapsed(hintText: null),
          contextMenuBuilder: (_, __) => const SizedBox.shrink(),
          onTap: () => setState(() {
            _bars = !_bars;
            _settings = false;
          }),
        ),
      ),
      if (selected || count > 0)
        Positioned(
          right: 8,
          top: 0,
          child: GestureDetector(
            onTap: () => _openParagraph(i),
            child: _CommentBubble(
              color: selected ? AppColors.orange : const Color(0xFF8A8A8A),
              count: count,
              selected: selected,
            ),
          ),
        ),
    ]);
  }

  Widget _banner(Part p) => SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(fit: StackFit.expand, children: [
          if (p.coverUrl != null)
            Image.network(p.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2A2A2A)))
          else
            Container(color: const Color(0xFF2A2A2A)),
          Container(color: Colors.black54),
        ]),
      );

  Widget _stat(IconData i, String t, _Palette pal) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(i, size: 22, color: pal.muted),
        const SizedBox(width: 6),
        Text(t, style: TextStyle(fontSize: 17, color: pal.muted)),
      ]);

  // ---------- Panel Aa ----------
  Widget _settingsPanel() {
    final selected = ReaderPrefs.follow ? 'dark' : ReaderPrefs.theme;

    Widget swatch(String key, Color c) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              ReaderPrefs.follow = false;
              ReaderPrefs.theme = key;
            }),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: c,
                border: selected == key
                    ? Border.all(color: AppColors.orange, width: 2)
                    : null,
              ),
            ),
          ),
        );

    Widget btn(String t, VoidCallback? onTap, {TextStyle? style}) => Material(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Text(t,
                  style: (style ?? const TextStyle(fontSize: 18))
                      .copyWith(color: onTap == null ? Colors.white24 : Colors.white)),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF262626),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Warna halaman',
              style: TextStyle(color: AppColors.muted, fontSize: 16)),
          const SizedBox(height: 4),
          Row(children: [
            const Expanded(
                child: Text('Ikuti pengaturan aplikasi Wetpad',
                    style: TextStyle(fontSize: 17, color: Colors.white))),
            Switch(
              value: ReaderPrefs.follow,
              activeTrackColor: AppColors.orange,
              thumbColor: const WidgetStatePropertyAll(Color(0xFF1B1B1B)),
              onChanged: (v) => setState(() => ReaderPrefs.follow = v),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            swatch('light', Colors.white),
            const SizedBox(width: 12),
            swatch('dark', Colors.black),
            const SizedBox(width: 12),
            swatch('sepia', const Color(0xFFFBF0D9)),
          ]),
          const SizedBox(height: 16),
          const Text('Font', style: TextStyle(color: AppColors.muted, fontSize: 16)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: btn('Aa-',
                  ReaderPrefs.fontSize <= 14
                      ? null
                      : () => setState(() => ReaderPrefs.fontSize -= 2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: btn('Aa+',
                  ReaderPrefs.fontSize >= 32
                      ? null
                      : () => setState(() => ReaderPrefs.fontSize += 2)),
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: btn(
              ReaderPrefs.serif ? 'Serif' : 'Sans Serif',
              () => setState(() => ReaderPrefs.serif = !ReaderPrefs.serif),
              style: _font(22),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Pengaturan lainnya...',
                  style: TextStyle(color: AppColors.muted, fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Bar bawah ----------
  Widget _barBtn(IconData i, String label, VoidCallback onTap,
      {Color color = AppColors.orange, Color? labelColor}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 30, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 14, color: labelColor ?? _pal.muted)),
        ]),
      ),
    );
  }

  Widget _bottomBar(Part p, _Palette pal) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        height: 28,
        child: Stack(children: [
          Positioned(
              left: 0,
              right: 0,
              top: 14,
              bottom: 0,
              child: ColoredBox(color: pal.bottom)),
          Positioned.fill(
            child: ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (_, v, __) => _ProgressBar(
                value: v,
                inactive: identical(pal, _Palette.dark)
                    ? const Color(0xFFE6E6E6)
                    : pal.muted,
                onChanged: (x) {
                  if (_scroll.hasClients) {
                    _scroll.jumpTo(x * _scroll.position.maxScrollExtent);
                  }
                },
              ),
            ),
          ),
        ]),
      ),
      Container(
        color: pal.bottom,
        child: SafeArea(
          top: false,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _barBtn(_voted ? Icons.star : Icons.star_border,
                _voted ? 'Voted' : 'Vote', _vote),
            _barBtn(Icons.chat_bubble_outline,
                '${p.commentsCount + _extraComments}', _openComments),
            _barBtn(Icons.bolt, 'Tanpa iklan', () {},
                color: AppColors.lavender, labelColor: AppColors.lavender),
            _barBtn(Icons.send_outlined, 'Bagikan', _share),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.orange, size: 28),
              onPressed: _showActions,
            ),
          ]),
        ),
      ),
    ]);
  }

  // ---------- Drawer daftar bab ----------
  Widget _drawer(Part p) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.71,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: ListView(padding: EdgeInsets.zero, children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white, width: 1.5)),
              child: SizedBox(
                width: 110,
                height: 180,
                child: p.coverUrl == null
                    ? Container(color: const Color(0xFF2A2A2A))
                    : Image.network(p.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFF2A2A2A))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(p.storyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(p.author,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SizedBox(
              height: 64,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white24,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: _inLibrary ? null : _addToLibrary,
                child: Text(_inLibrary ? 'Ada di Perpustakaan' : 'Tambahkan ke Perpustakaan'),
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          for (final it in _parts)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(it.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 18,
                      color: it.id == p.id ? AppColors.orange : Colors.white)),
              onTap: () {
                _scaffoldKey.currentState?.closeEndDrawer();
                if (it.id != p.id) _load(it.id);
              },
            ),
        ]),
      ),
    );
  }
}

// ---------- Progres baca (garis oranye + bulatan) ----------
class _ProgressBar extends StatelessWidget {
  final double value;
  final Color inactive;
  final ValueChanged<double> onChanged;
  const _ProgressBar(
      {required this.value, required this.inactive, required this.onChanged});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        const r = _ProgressPainter.r;
        void update(Offset p) =>
            onChanged(((p.dx - r) / (c.maxWidth - 2 * r)).clamp(0.0, 1.0));

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => update(d.localPosition),
          onHorizontalDragStart: (d) => update(d.localPosition),
          onHorizontalDragUpdate: (d) => update(d.localPosition),
          child: CustomPaint(
              size: Size(c.maxWidth, c.maxHeight),
              painter: _ProgressPainter(value, inactive)),
        );
      });
}

class _ProgressPainter extends CustomPainter {
  static const r = 11.0;
  final double value;
  final Color inactive;
  _ProgressPainter(this.value, this.inactive);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final x = r + value * (size.width - 2 * r);
    final back = Paint()
      ..color = inactive
      ..strokeWidth = 4;
    final front = Paint()
      ..color = AppColors.orange
      ..strokeWidth = 4;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), back);
    canvas.drawLine(Offset(0, y), Offset(x, y), front);
    canvas.drawCircle(Offset(x, y), r, Paint()..color = AppColors.orange);
    canvas.drawCircle(Offset(x, y), r - 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ProgressPainter old) =>
      old.value != value || old.inactive != inactive;
}

class _CommentBubble extends StatelessWidget {
  final Color color;
  final int count;
  final bool selected;
  const _CommentBubble(
      {required this.color, required this.count, required this.selected});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(color),
      child: SizedBox(
        width: 36,
        height: 32,
        child: Stack(children: [
          if (selected && count == 0)
            const Positioned(
                left: 4, top: 2, child: Text('', style: TextStyle(fontSize: 11)))
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Center(
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ]),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  _BubblePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const tail = 6.0;
    final p = Paint()..color = color;
    final body = Rect.fromLTWH(0, 0, size.width, size.height - tail);
    canvas.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(6)), p);

    // ekor balon di kiri bawah
    final t = Path()
      ..moveTo(2, body.bottom - 2)
      ..lineTo(14, body.bottom - 2)
      ..lineTo(1, size.height)
      ..close();
    canvas.drawPath(t, p);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.color != color;
}