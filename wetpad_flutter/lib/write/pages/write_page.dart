import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../widgets/continue_writing_card.dart';
import 'add_story_info_page.dart';
import 'edit_story_page.dart';
import 'series_page.dart';
import 'stories_page.dart';

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

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
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
          ValueListenableBuilder<WriteSummary?>(
            valueListenable: writeSummary,
            builder: (context, summary, _) {
              if (summary == null) {
                return const Divider(height: 1, color: kDivider);
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: ContinueWritingCard(
                  summary: summary,
                  onTap: () => _push(context, EditStoryPage(initial: summary)),
                ),
              );
            },
          ),
          _menuItem(
            icon: const Icon(Icons.menu_book_outlined, size: 28),
            label: 'Stories',
            onTap: () => _push(context, const StoriesPage()),
          ),
          _menuItem(
            icon: const Icon(Icons.view_week_outlined, size: 28),
            label: 'Series',
            onTap: () => _push(context, const SeriesPage()),
          ),
          _menuItem(
            icon: const Icon(Icons.note_add_outlined, size: 28),
            label: 'Create new story',
            onTap: () => _push(context, const AddStoryInfoPage()),
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
      ),
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
        const Divider(height: 1, color: Color.fromARGB(255, 27, 26, 26)),
      ],
    );
  }
}
