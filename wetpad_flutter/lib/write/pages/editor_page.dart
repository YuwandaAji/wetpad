import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import 'edit_story_page.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({
    super.key,
    this.partNumber = 1,
    this.totalParts = 1,
    this.onPublished,
  });

  final int partNumber;
  final int totalParts;

  /// Diisi saat editor dibuka dari Edit Story (ADD NEW PART).
  /// Dipanggil setelah publish dengan judul part yang baru.
  final void Function(String title)? onPublished;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _bodyFocus = FocusNode();
  final _undoCtrl = UndoHistoryController();
  final _picker = ImagePicker();

  Uint8List? _mediaBytes;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_onChanged);
    _bodyCtrl.addListener(_onChanged);
    _bodyFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _bodyFocus.dispose();
    _undoCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    // TODO: simpan draft ke API. Untuk sekarang hanya mengubah label.
    setState(() {
      _saved = _titleCtrl.text.isNotEmpty || _bodyCtrl.text.isNotEmpty;
    });
  }

  int get _wordCount {
    final text = _bodyCtrl.text.trim();
    return text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  }

  bool get _canPublish => _bodyCtrl.text.trim().isNotEmpty;

  String _readTime() {
    final seconds = (_wordCount / 200 * 60).round().clamp(1, 1 << 30);
    if (seconds < 60) return '$seconds second${seconds == 1 ? '' : 's'}';
    final minutes = (seconds / 60).round();
    return '$minutes minute${minutes == 1 ? '' : 's'}';
  }

  Future<void> _pickMedia() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _mediaBytes = bytes);
  }

  void _confirmPublish() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF424242),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text(
          'Confirm Publish',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Your story part takes ${_readTime()} to read.\n'
          'Ready to make this part of your story visible to readers on Wetpad?',
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'WRITE MORE',
              style: TextStyle(color: kOrange, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _publish();
            },
            child: const Text(
              'PUBLISH NOW',
              style: TextStyle(color: kOrange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _publish() {
    // TODO: kirim judul, isi, dan media ke API (menunggu endpoint backend)
    final title = _titleCtrl.text.trim();

    // Dibuka dari Edit Story (ADD NEW PART): kabari halaman itu lalu kembali.
    if (widget.onPublished != null) {
      widget.onPublished!(title);
      Navigator.pop(context);
      return;
    }

    // Alur pertama kali: setelah publish, tampilkan Edit Story.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EditStoryPage(
          partTitles: [title.isEmpty ? 'Untitled Part 1' : title],
        ),
      ),
    );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Part ${widget.partNumber} of ${widget.totalParts}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            if (_saved)
              const Text(
                'Saved just now',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _canPublish ? _confirmPublish : null,
            child: Text(
              'PUBLISH',
              style: TextStyle(
                color: _canPublish ? Colors.white : Colors.white24,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: menu (hapus part, pengaturan, dll.)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mediaBox(),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _titleCtrl,
                    textAlign: TextAlign.center,
                    cursorColor: kOrange,
                    style: const TextStyle(fontFamily: 'serif', fontSize: 26),
                    decoration: const InputDecoration(
                      hintText: 'Title your Story Part',
                      hintStyle: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 26,
                        color: Colors.grey,
                      ),
                      contentPadding: EdgeInsets.only(bottom: 8),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bodyCtrl,
                    focusNode: _bodyFocus,
                    undoController: _undoCtrl,
                    minLines: 6,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    cursorColor: kOrange,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 20,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tap here to start writing',
                      hintStyle: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: tambah polling
                    },
                    icon: const Icon(Icons.playlist_add, color: Colors.grey),
                    label: const Text(
                      'Add a poll',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_bodyFocus.hasFocus) _bottomBar(),
        ],
      ),
    );
  }

  Widget _mediaBox() {
    return GestureDetector(
      onTap: _pickMedia,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          height: 200,
          width: double.infinity,
          alignment: Alignment.center,
          child: _mediaBytes == null
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 44,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to add media',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    _mediaBytes!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              '$_wordCount word${_wordCount == 1 ? '' : 's'}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
        Container(
          color: kGreyField,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.undo, color: kOrange),
                onPressed: _undoCtrl.undo,
              ),
              IconButton(
                icon: const Icon(Icons.redo, color: kOrange),
                onPressed: _undoCtrl.redo,
              ),
              IconButton(
                icon: const Icon(Icons.text_format, color: kOrange, size: 30),
                onPressed: () {
                  // TODO: format teks
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_photo_alternate, color: kOrange),
                onPressed: _pickMedia,
              ),
              IconButton(
                icon: const Icon(Icons.smart_display, color: kOrange),
                onPressed: () {
                  // TODO: sisipkan video
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Garis putus-putus untuk kotak "Tap to add media".
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
