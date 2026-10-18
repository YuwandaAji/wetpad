import 'package:flutter/material.dart';

import '../widgets/library_style.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static InlineSpan _icon(IconData icon) => WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(icon, size: 24, color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final items = <_FaqItem>[
      _FaqItem('Why is there a new way to read offline on Wattpad?', [
        [
          const TextSpan(
              text: 'Offline reading makes it possible to take your favorite '
                  'Wattpad stories with you on the go—without being connected '
                  'to the internet. The new Library management experience makes '
                  'it easy to add and remove stories from your Offline List '
                  'with the tap of a button. Connect to the internet '
                  'momentarily, add a story to your Offline List with a single '
                  'tap, and enjoy diving into your next obsession wherever you '
                  'are—no internet needed.')
        ],
        [
          const TextSpan(
              text: 'Issues with the previous version of Library management '
                  'resulted in Wattpadders having a lack of control over '
                  'automatic downloads, device storage overload, Library '
                  'syncing issues, and app crashes—which is not the offline '
                  'experience we want to provide.')
        ],
        [
          const TextSpan(
              text: 'You now have total control over the stories you save for '
                  'offline reading by curating an Offline List based on your '
                  'needs and preferences. You tell Wattpad when and how to use '
                  'your internet connection and device storage.')
        ],
      ]),
      _FaqItem('How can I add a story to read offline?', [
        [
          const TextSpan(
              text: 'To add a story to your Offline list, you can visit your '
                  'Library and tap the'),
          _icon(Icons.cloud_download_outlined),
          const TextSpan(
              text: 'icon followed by “Add to Offline list” where the story is '
                  'listed. You must be connected to the internet to add a '
                  'story to your Offline list.'),
        ],
      ]),
      _FaqItem('How can I remove a story from my Offline list?', [
        [
          const TextSpan(
              text: 'To remove a story, go to your Library and tap the'),
          _icon(Icons.more_vert),
          const TextSpan(
              text: 'icon next to the story you wish to remove, followed by '
                  '“Remove from Offline list”.'),
        ],
      ]),
      _FaqItem('How can I tell if a story is available offline?', [
        [
          const TextSpan(
              text: 'If you want to confirm which stories are available for '
                  'offline reading, visit the “Available Offline” section of '
                  'your Library or look out for the'),
          _icon(Icons.check),
          const TextSpan(
              text: 'icon next to each story. We will inform you if you '
                  'attempt to read an online story while you are not connected '
                  'to the internet.'),
        ],
      ]),
      _FaqItem('Do Wattpad Originals count towards my offline limit?', [
        [
          const TextSpan(
              text: 'Any Wattpad Originals you have added to your Library will '
                  'be available for offline reading and will not count '
                  'towards your offline limit.')
        ],
      ]),
      _FaqItem('How can I change my offline limit?', [
        [
          const TextSpan(
              text: 'You can remove your offline limit and access unlimited '
                  'stories offline by subscribing to Wattpad Premium.')
        ],
      ]),
      _FaqItem(
          'If I remove a story from my Offline list, will it also be removed '
          'from my Library?',
          [
            [
              const TextSpan(
                  text: 'Removing a story from your Offline list does not '
                      'remove it from your Library. Stories you remove from '
                      'your Offline list will be moved into the “Other '
                      'Stories” section of your Library.')
            ],
          ]),
      _FaqItem(
          'I am trying to add a story to my Offline list but it is not '
          'getting added. Why is this the case?',
          [
            [
              const TextSpan(
                  text: 'If you have attempted to add a story to your Offline '
                      'list but are unable to do so, this may be because:')
            ],
            [
              const TextSpan(
                  text: '1. You do not have an active internet connection to '
                      'add the story. Connect to the internet to add new '
                      'stories to your Offline list.')
            ],
            [
              const TextSpan(
                  text: '2. You have reached your offline limit. You can '
                      'either remove an offline story to add another story '
                      'for offline reading, or subscribe to Wattpad Premium '
                      'to access unlimited stories offline.')
            ],
          ]),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, thickness: 1, color: LibColors.tabBar),
        itemBuilder: (_, i) {
          final item = items[i];
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.question,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.45)),
                const SizedBox(height: 16),
                for (var p = 0; p < item.paragraphs.length; p++)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: p == item.paragraphs.length - 1 ? 0 : 16),
                    child: Text.rich(
                      TextSpan(children: item.paragraphs[p]),
                      style: const TextStyle(fontSize: 17, height: 1.45),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FaqItem {
  _FaqItem(this.question, this.paragraphs);
  final String question;
  final List<List<InlineSpan>> paragraphs;
}
