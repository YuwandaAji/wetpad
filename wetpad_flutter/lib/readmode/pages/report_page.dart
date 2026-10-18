
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../services/read_api.dart';

class _Opt {
  final String label;
  final String? desc;
  final _Node next;
  _Opt(this.label, this.next, [this.desc]);
}

class _Node {
  final String title;
  final String? question;
  final List<_Opt> options;
  final String? formIntro; // kalau diisi: layar form
  _Node(this.title, {this.question, this.options = const [], this.formIntro});
}

const _generic = 'Mohon berikan detail sebanyak mungkin dan tautan ke bab cerita.';
_Node _form(String title, String intro) => _Node(title, formIntro: intro);

final _inappropriate = _Node(
  'Konten Tidak Pantas',
  question: 'Kenapa cerita ini tidak pantas?',
  options: [
    _Opt(
      'Konten Eksplisit',
      _form('Konten Eksplisit',
          'Mohon berikan detail sebanyak mungkin dan tautan ke bab cerita. Contoh: Bab 2–6 hanya berisi teks pornografi tanpa plot. Atau: Ada gambar pornografi di header bab ketiga.'),
      'Ini bisa termasuk pornografi berupa teks, gambar dan lainnya.',
    ),
    _Opt('Kebencian & Pelecehan', _form('Kebencian & Pelecehan', _generic),
        'Ini bisa termasuk perundungan, ujaran kebencian, dan lainnya.'),
    _Opt('Kekerasan', _form('Kekerasan', _generic),
        'Ini bisa termasuk glorifikasi tindakan kekerasan, media yang memuat kekerasan, dan lainnya.'),
    _Opt('Penyebaran Informasi Pribadi', _form('Penyebaran Informasi Pribadi', _generic),
        'Ini termasuk membagikan informasi identitas seperti alamat kamu, gambar kamu, atau informasi kontak.'),
    _Opt('Menyakiti diri sendiri', _form('Menyakiti diri sendiri', _generic),
        'Ini bisa dalam bentuk teks, media, dan ancaman melukai diri sendiri dan/atau mendorong orang lain untuk melakukan hal yang sama.'),
    _Opt('Spam', _form('Spam', _generic),
        'Ini bisa termasuk iklan yang tidak diinginkan, tautan menyesatkan, dan lainnya.'),
  ],
);

final _copyright = _Node(
  'Pelanggaran Hak Cipta',
  question: 'Apa kamu pemilik asli dari hak cipta karya ini?',
  options: [
    _Opt('Saya bukan pemilik asli dari hak cipta',
        _form('Bukan pemilik hak cipta', _generic),
        'Saya tidak menulis karya ini & tidak memiliki izin dari pemegang hak cipta.'),
    _Opt('Saya adalah pemilik hak cipta asli',
        _form('Pemilik hak cipta asli', _generic),
        'Saya adalah pemilik atau diberi wewenang secara hukum atas nama pemilik.'),
  ],
);

final _root = _Node(
  'Laporkan Cerita',
  question: 'Kenapa kamu melaporkan cerita ini?',
  options: [
    _Opt('Konten Tidak Pantas', _inappropriate),
    _Opt('Pelanggaran Hak Cipta', _copyright),
  ],
);

const _grey = Color(0xFF6B6B6B);

class ReportPage extends StatefulWidget {
  final int storyId;
  final String reasonPrefix;
  const ReportPage({super.key, required this.storyId, this.reasonPrefix = ''});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final List<_Node> _stack = [_root];
  final _detail = TextEditingController();
  bool _sending = false;

  _Node get _cur => _stack.last;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  void _push(_Node n) {
    _detail.clear();
    setState(() => _stack.add(n));
  }

  void _back() {
    if (_stack.length > 1) {
      setState(() => _stack.removeLast());
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    try {
      final reason = widget.reasonPrefix + _stack.skip(1).map((n) => n.title).join(' > ');
      await ReadApi.reportStory(widget.storyId, reason, _detail.text.trim());
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Widget _header(_Node n) => _stack.length == 1
      ? Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          child: Text(n.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)))
      : Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back, size: 28), onPressed: _back),
            const SizedBox(width: 24),
            Expanded(
                child: Text(n.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          ]),
        );

  Widget _option(_Opt o) => InkWell(
        onTap: () => _push(o.next),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 24, 16),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.label, style: const TextStyle(fontSize: 20)),
                if (o.desc != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(o.desc!,
                        style: const TextStyle(fontSize: 16, color: _grey, height: 1.5)),
                  ),
              ]),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.chevron_right, color: _grey, size: 30),
          ]),
        ),
      );

  Widget _formBody(_Node n) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      borderSide: BorderSide(color: Colors.black87, width: 1.5),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(n.formIntro!, style: const TextStyle(fontSize: 18, color: _grey, height: 1.6)),
        const SizedBox(height: 16),
        TextField(
          controller: _detail,
          minLines: 5,
          maxLines: 5,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFFFAFAFA),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bg,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: _sending ? null : _submit,
            child: _sending
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Kirim Laporan'),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = _cur;
    return Theme(
      data: ThemeData.light(useMaterial3: true),
      child: PopScope(
        canPop: _stack.length == 1,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            Container(
              color: AppColors.bg,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 56,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
                _header(n),
                if (n.question != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(n.question!,
                        style: const TextStyle(fontSize: 18, color: _grey)),
                  ),
                if (n.formIntro != null) _formBody(n) else ...n.options.map(_option),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}