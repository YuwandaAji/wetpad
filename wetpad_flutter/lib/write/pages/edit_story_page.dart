import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../widgets/continue_writing_card.dart';
import 'editor_page.dart';
import 'published_page.dart';

const _requiredColor = Color(0xFFFF5A36);

class EditStoryPage extends StatefulWidget {
  const EditStoryPage({
    super.key,
    this.initial,
    this.storyTitle = 'Default Title - Write Your Own',
    this.description = '',
    this.coverBytes,
    this.partTitles = const [],
  });

  /// Dibuka dari kartu "Continue writing": semua data cerita dibawa ke sini.
  final WriteSummary? initial;

  /// Dipakai saat cerita baru (alur pertama kali dari Editor).
  final String storyTitle;
  final String description;
  final Uint8List? coverBytes;
  final List<String> partTitles;

  @override
  State<EditStoryPage> createState() => _EditStoryPageState();
}

class _EditStoryPageState extends State<EditStoryPage> {
  final _picker = ImagePicker();

  late String _title = widget.initial?.title ?? widget.storyTitle;
  late String _description = widget.initial?.description ?? widget.description;
  late Uint8List? _cover = widget.initial?.coverBytes ?? widget.coverBytes;
  late final List<String> _parts = [
    ...(widget.initial?.partTitles ?? widget.partTitles),
  ];
  late String _language = widget.initial?.language ?? 'English';
  late String _storyType = widget.initial?.storyType ?? '';
  late String _tags = widget.initial?.tags ?? '';
  late String _copyright = widget.initial?.copyright ?? 'All Rights Reserved';
  late bool _mature = widget.initial?.mature ?? false;
  late bool _completed = widget.initial?.completed ?? false;

  @override
  void initState() {
    super.initState();
    // Simpan ke ringkasan supaya kartu "Continue writing" ikut terisi.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _sync() {
    writeSummary.value = WriteSummary(
      title: _title,
      description: _description,
      partTitles: List.of(_parts),
      coverBytes: _cover,
      language: _language,
      storyType: _storyType,
      tags: _tags,
      copyright: _copyright,
      mature: _mature,
      completed: _completed,
    );
  }

  /// setState + simpan ke ringkasan.
  void _update(VoidCallback change) {
    setState(change);
    _sync();
  }

  List<String> get _tagList =>
      _tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickCover() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    _update(() => _cover = bytes);
  }

  Future<String?> _editText(
    String label,
    String initial, {
    bool multiline = false,
  }) async {
    final ctrl = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          minLines: multiline ? 4 : 1,
          maxLines: multiline ? 8 : 1,
          keyboardType: multiline
              ? TextInputType.multiline
              : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('OK', style: TextStyle(color: kOrange)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }

  Future<String?> _pickOption(
    String title,
    List<String> options,
    String current,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            for (final o in options)
              ListTile(
                title: Text(o),
                trailing: o == current
                    ? const Icon(Icons.check, color: kOrange)
                    : null,
                onTap: () => Navigator.pop(ctx, o),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTitle() async {
    final v = await _editText('Story Title', _title);
    if (v != null && v.isNotEmpty) _update(() => _title = v);
  }

  Future<void> _editDescription() async {
    final v = await _editText(
      'Story Description',
      _description,
      multiline: true,
    );
    if (v != null) _update(() => _description = v);
  }

  Future<void> _editLanguage() async {
    final v = await _pickOption('Language', const [
      'English',
      'Bahasa Indonesia',
    ], _language);
    if (v != null) _update(() => _language = v);
  }

  Future<void> _editStoryType() async {
    final v = await _pickOption('Story type', const [
      'Original',
      'Fanfiction',
    ], _storyType);
    if (v != null) _update(() => _storyType = v);
  }

  Future<void> _editTags() async {
    final v = await _editText('Tags (pisahkan dengan koma)', _tags);
    if (v != null) _update(() => _tags = v);
  }

  Future<void> _editCopyright() async {
    final v = await _pickOption('Copyright', const [
      'All Rights Reserved',
      'Public Domain',
      'Creative Commons',
    ], _copyright);
    if (v != null) _update(() => _copyright = v);
  }

  void _addPart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditorPage(
          partNumber: _parts.length + 1,
          totalParts: _parts.length + 1,
          coverBytes: _cover,
          tags: _tagList,
          onPublished: (title) {
            _update(() {
              _parts.add(
                title.isEmpty ? 'Untitled Part ${_parts.length + 1}' : title,
              );
            });
          },
        ),
      ),
    );
  }

  void _openPart(int index) {
    // TODO: muat isi part dari API. Sementara hanya membuka editor kosong.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditorPage(
          partNumber: index + 1,
          totalParts: _parts.length,
          coverBytes: _cover,
          tags: _tagList,
        ),
      ),
    );
  }

  Future<void> _saveAndPublish() async {
    final missing = <String>[
      if (_title.trim().isEmpty) 'Story Title',
      if (_description.trim().isEmpty) 'Story Description',
      if (_storyType.isEmpty) 'Story type',
      if (_tags.trim().isEmpty) 'Tags',
    ];
    if (missing.isNotEmpty) {
      _toast('Lengkapi dulu: ${missing.join(', ')}');
      return;
    }
    if (_parts.isEmpty) {
      _toast('Tambahkan minimal satu part');
      return;
    }
    // TODO: kirim ke API (menunggu endpoint dari backend)
    _sync();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublishedPage(
          partNumber: _parts.length,
          partTitle: _parts.last,
          coverBytes: _cover,
          tags: _tagList,
        ),
      ),
    );
    if (!mounted) return;
    Navigator.pop(context); // DONE: kembali ke halaman Write
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Edit Story',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
              onPressed: _saveAndPublish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Save & Publish',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: _addPart),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: menu (hapus cerita, dan lain-lain)
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            color: kGreyField,
            padding: const EdgeInsets.all(24),
            child: const Text(
              'By publishing on Wetpad, I acknowledge that this is my own '
              'original work or that I have permission from the original '
              'author to post this work. Copyright infringement may result '
              'in story deletion or account closure.',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
          _coverRow(),
          const Divider(height: 1, color: kDivider, indent: 24, endIndent: 24),
          _FieldRow(
            label: 'Story Title',
            isRequired: true,
            value: _title,
            onTap: _editTitle,
          ),
          _FieldRow(
            label: 'Story Description',
            isRequired: true,
            value: _description,
            onTap: _editDescription,
          ),
          _FieldRow(label: 'Language', value: _language, onTap: _editLanguage),
          _FieldRow(
            label: 'Story type',
            isRequired: true,
            value: _storyType,
            badge: const _NewBadge(),
            onTap: _editStoryType,
          ),
          _FieldRow(
            label: 'Tags',
            isRequired: true,
            value: _tags,
            onTap: _editTags,
          ),
          _FieldRow(
            label: 'Copyright',
            value: _copyright,
            onTap: _editCopyright,
          ),
          _SwitchRow(
            title: 'Mature',
            subtitle:
                'Your story is appropriate for all audiences. The '
                'Wetpad community has the ability to rate your story Mature. '
                'For more info, check the Content Guidelines under Settings.',
            value: _mature,
            onChanged: (v) => _update(() => _mature = v),
          ),
          _SwitchRow(
            title: 'Completed Story',
            value: _completed,
            onChanged: (v) => _update(() => _completed = v),
          ),
          _tocHeader(),
          for (var i = 0; i < _parts.length; i++) _partTile(i),
          _addPartBox(),
        ],
      ),
    );
  }

  Widget _coverRow() {
    return InkWell(
      onTap: _pickCover,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 82,
              height: 130,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: kGreyField,
                borderRadius: BorderRadius.circular(6),
              ),
              child: _cover == null
                  ? const Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: Colors.grey,
                    )
                  : Image.memory(_cover!, fit: BoxFit.cover),
            ),
            const SizedBox(width: 24),
            const Text(
              'Edit Story Cover',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tocHeader() {
    return Container(
      width: double.infinity,
      color: kGreyField,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Table of Contents',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              // TODO: atur urutan part
            },
          ),
        ],
      ),
    );
  }

  Widget _partTile(int index) {
    return InkWell(
      onTap: () => _openPart(index),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _parts[index],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Draft - updated Today',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: kDivider, indent: 24, endIndent: 24),
        ],
      ),
    );
  }

  Widget _addPartBox() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: InkWell(
        onTap: _addPart,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: const SizedBox(
            height: 110,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'ADD NEW PART',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.onTap,
    this.value,
    this.isRequired = false,
    this.badge,
  });

  final String label;
  final String? value;
  final bool isRequired;
  final Widget? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 6),
                            const Text(
                              '*Required',
                              style: TextStyle(
                                fontSize: 17,
                                color: _requiredColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (hasValue) ...[
                        const SizedBox(height: 4),
                        Text(
                          value!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (badge != null) badge!,
              ],
            ),
          ),
          const Divider(height: 1, color: kDivider, indent: 24, endIndent: 24),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: kOrange,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: kDivider, indent: 24, endIndent: 24),
      ],
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFA5D6A7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Color(0xFF1B5E20),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      );
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}