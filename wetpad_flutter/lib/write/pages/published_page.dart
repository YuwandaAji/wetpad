import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';

const _pageBg = Color(0xFF4A4A4A);

class PublishedPage extends StatelessWidget {
  const PublishedPage({
    super.key,
    required this.partNumber,
    required this.partTitle,
    this.coverBytes,
    this.tags = const [],
  });

  final int partNumber;
  final String partTitle;
  final Uint8List? coverBytes;
  final List<String> tags;

  String get _partLabel =>
      partTitle.isEmpty ? 'Part $partNumber' : 'Part $partNumber: $partTitle';

  // TODO: tambahkan link cerita kalau sudah ada halaman webnya
  String get _shareText =>
      'Aku baru saja mempublikasikan "$_partLabel" di Wetpad!';

  Future<void> _share() async {
    await SharePlus.instance.share(ShareParams(text: _shareText));
  }

  Future<void> _shareWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(_shareText)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Congratulations',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _section(
              child: Column(
                children: [
                  const Text(
                    'You just published',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 16),
                  _cover(),
                  const SizedBox(height: 16),
                  Text(
                    _partLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Your story can be found here',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [for (final t in tags) _TagChip(t)],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(
              child: Column(
                children: [
                  const Text(
                    'Share and get discovered',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _ShareButton(
                          color: const Color(0xFF3B5998),
                          icon: FontAwesomeIcons.instagram,
                          // Instagram tidak punya link share teks,
                          // jadi memakai menu share bawaan HP.
                          onTap: _share,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShareButton(
                          color: const Color(0xFF25D366),
                          icon: FontAwesomeIcons.whatsapp,
                          onTap: () => _shareWhatsApp(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShareButton(
                          color: const Color(0xFFB0B0B0),
                          icon: FontAwesomeIcons.shareNodes,
                          onTap: _share,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      width: double.infinity,
      color: kBg,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: child,
    );
  }

  Widget _cover() {
    return SizedBox(
      width: 92,
      height: 142,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: coverBytes == null
                  ? Container(
                      color: kGreyField,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: Colors.grey,
                      ),
                    )
                  : Image.memory(coverBytes!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: 6,
            top: 4,
            child: Text(
              '$partNumber',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final Color color;
  final FaIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 62,
          child: Center(child: FaIcon(icon, color: Colors.white, size: 26)),
        ),
      ),
    );
  }
}
