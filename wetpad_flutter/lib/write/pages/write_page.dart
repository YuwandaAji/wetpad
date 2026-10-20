import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import 'add_story_info_page.dart';
import 'series_page.dart';
import 'editor_page.dart';

const _writingResourcesUrl = 'https://creators.wattpad.com/writing-resources/';

class WritePage extends StatelessWidget {
  const WritePage({super.key});

  Future<void> _openLink(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tidak bisa membuka link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                const Text(
                  'Write',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Text(
                  '@rozakl', // TODO: ambil dari Session
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: kDivider),
        _menuItem(
          icon: const Icon(Icons.view_week_outlined, size: 28),
          label: 'Series',
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SeriesPage()));
          },
        ),
        _menuItem(
          icon: const Icon(Icons.note_add_outlined, size: 28),
          label: 'Create new story',
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddStoryInfoPage()));
          },
        ),
        _menuItem(
          icon: _circleIcon(Icons.menu_book),
          label: 'Writing resources',
          onTap: () => _openLink(context, _writingResourcesUrl),
        ),
        _menuItem(
          icon: _circleIcon(Icons.star),
          label: 'Programs & opportunities',
          onTap: () => _openLink(context, _writingResourcesUrl),
        ),
      ],
    );
  }

  static Widget _circleIcon(IconData data) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(data, size: 16, color: Colors.black),
    );
  }

  static Widget _menuItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                SizedBox(width: 28, child: icon),
                const SizedBox(width: 28),
                Text(label, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: kDivider),
      ],
    );
  }
}
