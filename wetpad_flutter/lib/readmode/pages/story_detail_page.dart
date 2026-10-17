// lib/features/readmode/pages/story_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/format.dart';
import '../../../core/theme.dart';
import '../models/story.dart';
import '../services/read_api.dart';
import 'reader_page.dart';
import 'package:share_plus/share_plus.dart';
import 'report_page.dart';

class StoryDetailPage extends StatefulWidget {
  final int storyId;
  final int? pagerCount;
  final int pagerIndex;
  const StoryDetailPage({
    super.key,
    required this.storyId,
    this.pagerCount,
    this.pagerIndex = 0,
  });

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Story? _story;
  List<PartItem> _parts = [];
  List<StoryMini> _recs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Future.wait<Object>([
        ReadApi.getStory(widget.storyId),
        ReadApi.getParts(widget.storyId),
        ReadApi.getRecommendations(widget.storyId)
            .catchError((_) => <StoryMini>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _story = r[0] as Story;
        _parts = r[1] as List<PartItem>;
        _recs = r[2] as List<StoryMini>;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _read(int partId) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => ReaderPage(partId: partId)));

  Future<void> _share() async {
    final s = _story!;
    final text = '${s.title} oleh ${s.authorName ?? '-'}\nhttps://wetpad.app/story/${s.id}';
    try {
      final r = await SharePlus.instance.share(ShareParams(text: text, subject: s.title));
      if (r.status == ShareResultStatus.unavailable) throw 'unavailable';
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Tautan disalin')));
      }
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
            leading: const Icon(Icons.send_outlined, size: 28),
            title: const Text('Bagikan', style: TextStyle(fontSize: 20)),
            onTap: () {
              Navigator.pop(ctx);
              _share();
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined, size: 28),
            title: const Text('Laporkan', style: TextStyle(fontSize: 20)),
            onTap: () async {
              Navigator.pop(ctx);
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => ReportPage(storyId: widget.storyId),
                ),
              );
              if (ok == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Laporan terkirim. Terima kasih!')));
              }
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showAddTo() {
    // TODO: sambungkan ke POST /library dan /reading-lists setelah endpoint jadi
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tambah ke',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          ),
          ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: const Text('Perpustakaan'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await ReadApi.addToLibrary(widget.storyId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ditambahkan ke perpustakaan')));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
              },),
          ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Daftar bacaan'),
              onTap: () => Navigator.pop(ctx)),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_error != null) {
      return Scaffold(
          appBar: AppBar(),
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Gagal memuat: $_error', textAlign: TextAlign.center))));
    }
    final s = _story;
    if (s == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.orange)));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.maybePop(context)),
              actions: [
                IconButton(icon: const Icon(Icons.more_vert), onPressed: _showActions),
              ],
            ),
            SliverToBoxAdapter(
              child: _Header(story: s, pagerCount: widget.pagerCount, pagerIndex: widget.pagerIndex),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(const TabBar(
                tabs: [Tab(text: 'Ringkasan'), Tab(text: 'Bab')],
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.muted,
                labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                indicatorColor: AppColors.orange,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.white10,
              )),
            ),
          ],
          body: TabBarView(children: [
            _SummaryTab(story: s, recs: _recs),
            _PartsTab(parts: _parts, onTap: _read),
          ]),
        ),
        bottomNavigationBar: _BottomBar(
          onRead: () {
            if (_parts.isNotEmpty) _read(_parts.first.id);
          },
          onAdd: _showAddTo,
        ),
      ),
    );
  }
}

// ---------- Header ----------
class _Header extends StatelessWidget {
  final Story story;
  final int? pagerCount;
  final int pagerIndex;
  const _Header({required this.story, this.pagerCount, this.pagerIndex = 0});

  Widget _stat(IconData i, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(i, size: 22),
        const SizedBox(width: 4),
        Text(t, style: const TextStyle(fontSize: 15)),
      ]);

  @override
  Widget build(BuildContext context) {
    final avatar = story.authorAvatar;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(children: [
        if (pagerCount != null && pagerCount! > 1) ...[
          _Dots(count: pagerCount!, index: pagerIndex),
          const SizedBox(height: 24),
        ] else
          const SizedBox(height: 8),
        SizedBox(
          height: 162,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Cover(story.coverUrl, 105, 162),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF3A3A3A),
                        backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                        child: avatar == null
                            ? const Icon(Icons.person, size: 20, color: AppColors.muted)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                          child: Text(story.authorName ?? '-',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 17))),
                    ]),
                  ]),
                  Wrap(spacing: 14, runSpacing: 4, children: [
                    _stat(Icons.remove_red_eye_outlined, fmtCount(story.readsTotal)),
                    _stat(Icons.star_border, fmtCount(story.votesTotal)),
                    _stat(Icons.format_list_bulleted, '${story.partsCount} bagian'),
                  ]),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 28),
        Row(children: const [
          Expanded(child: Divider(color: Colors.white24)),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Iklan', style: TextStyle(color: AppColors.muted))),
          Expanded(child: Divider(color: Colors.white24)),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count, index;
  const _Dots({required this.count, required this.index});

  Widget _dot(double w, Color c) => Container(
      width: w,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)));

  @override
  Widget build(BuildContext context) {
    const maxDots = 6;
    final start = (index - 2).clamp(0, (count - maxDots).clamp(0, count)).toInt();
    final end = (start + maxDots).clamp(0, count).toInt();
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (var i = start; i < end; i++)
        i == index
            ? _dot(36, AppColors.orange)
            : _dot(
                ((i == start && start > 0) || (i == end - 1 && end < count)) ? 5 : 8,
                const Color(0xFF3A3A3A)),
    ]);
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  final double w, h;
  const _Cover(this.url, this.w, this.h);

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(width: w, height: h, child: _CoverImage(url)),
      );
}

class _CoverImage extends StatelessWidget {
  final String? url;
  const _CoverImage(this.url);

  Widget _ph() => Container(
      color: const Color(0xFF2A2A2A),
      child: const Icon(Icons.book, color: AppColors.muted));

  @override
  Widget build(BuildContext context) => url == null
      ? _ph()
      : Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph());
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext c, double shrink, bool overlaps) =>
      Container(color: AppColors.bg, child: tabBar);

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => false;
}

// ---------- Tab Bab ----------
class _PartsTab extends StatelessWidget {
  final List<PartItem> parts;
  final void Function(int) onTap;
  const _PartsTab({required this.parts, required this.onTap});

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: parts.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
        itemBuilder: (_, i) {
          final p = parts[i];
          return InkWell(
            onTap: () => onTap(p.id),
            child: Container(
              height: 69,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(child: Text(p.title, style: const TextStyle(fontSize: 18))),
                Text(p.createdAt == null ? '' : fmtDate(p.createdAt!),
                    style: const TextStyle(color: AppColors.muted, fontSize: 15)),
              ]),
            ),
          );
        },
      );
}

// ---------- Tab Ringkasan ----------
class _SummaryTab extends StatefulWidget {
  final Story story;
  final List<StoryMini> recs;
  const _SummaryTab({required this.story, required this.recs});

  @override
  State<_SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<_SummaryTab> {
  int _sel = 0;

  Widget _infoRow(IconData i, String t, {bool bold = false}) => Row(children: [
        Icon(i, size: 24),
        const SizedBox(width: 14),
        Expanded(
            child: Text(t,
                style: TextStyle(
                    fontSize: 17, fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
      ]);

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    final recs = widget.recs;
    final sel = recs.isEmpty ? null : recs[_sel.clamp(0, recs.length - 1)];

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(children: [
          _infoRow(Icons.menu_book_outlined,
              s.status == 'completed' ? 'Tamat' : 'Bersambung',
              bold: true),
          if (s.lastPublished != null) ...[
            const SizedBox(height: 18),
            _infoRow(Icons.campaign_outlined,
                'Publikasi terakhir ${fmtDate(s.lastPublished!)}'),
          ],
          const SizedBox(height: 18),
          _infoRow(Icons.info_outline, 'Fiksi  •  ${s.genre ?? '-'}'),
        ]),
      ),
      const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),

      // Tagar
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Tagar', style: TextStyle(fontSize: 17))),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: s.tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                            color: AppColors.chip, borderRadius: BorderRadius.circular(8)),
                        child: Text(t,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ),
        ]),
      ),

      // Deskripsi
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _ExpandableText(s.description ?? ''),
      ),
      const SizedBox(height: 16),
      const Divider(color: Colors.white10, height: 1),

      // Premium
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.premiumBg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Row(children: [
            const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF4A467A),
                child: Icon(Icons.bolt, color: AppColors.lavender, size: 34)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Beralih ke bebas iklan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Membaca tanpa gangguan',
                    style: TextStyle(color: AppColors.muted, fontSize: 16)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lavender,
                foregroundColor: const Color(0xFF1B1B2F),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              onPressed: () {},
              child: const Text('Coba Premium'),
            ),
          ),
        ]),
      ),
      const Divider(color: Colors.white10, height: 1),

      // Rekomendasi
      if (sel != null) ...[
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 14),
          child: Text('Kamu mungkin juga menyukai ini',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final on = i == _sel;
              return GestureDetector(
                onTap: () => setState(() => _sel = i),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: on ? 100 : 94,
                    height: on ? 155 : 146,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                    child: _CoverImage(recs[i].coverUrl),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
          child: Row(children: [
            Expanded(
                child: Text(sel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Icon(Icons.format_list_bulleted, size: 18, color: AppColors.muted),
            const SizedBox(width: 6),
            Text('${sel.partsCount} bab',
                style: const TextStyle(color: AppColors.muted, fontSize: 16)),
            const Text('   •   ', style: TextStyle(color: AppColors.muted)),
            Text(sel.status == 'completed' ? 'Tamat' : 'Bersambung',
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
        ),

        if ((sel.description ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(sel.description!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 16, height: 1.5)),
          ),
          
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StoryDetailPage(storyId: sel.id))),
            child: Row(mainAxisSize: MainAxisSize.min, children: const [
              Text('Detail lengkap',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.chevron_right, color: Colors.white),
            ]),
          ),
        ),
      ],
    ]);
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText(this.text);

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _open = false;
  static const _style = TextStyle(fontSize: 17, height: 1.5);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final tp = TextPainter(
        text: TextSpan(text: widget.text, style: _style),
        maxLines: 3,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: c.maxWidth);

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.text,
            style: _style,
            maxLines: _open ? null : 3,
            overflow: _open ? TextOverflow.clip : TextOverflow.ellipsis),
        if (tp.didExceedMaxLines)
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_open ? 'Tampilkan lebih sedikit' : 'Baca selengkapnya',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
      ]);
    });
  }
}

// ---------- Bottom bar ----------
class _BottomBar extends StatelessWidget {
  final VoidCallback onRead, onAdd;
  const _BottomBar({required this.onRead, required this.onAdd});

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.bg,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SafeArea(
          top: false,
          child: Row(children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: onRead,
                  child: const Text('Mulai membaca'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 56,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                ),
                onPressed: onAdd,
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ]),
        ),
      );
}