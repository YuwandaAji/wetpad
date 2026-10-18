import 'package:flutter/material.dart';

import '../screens/library_data.dart';
import 'library_style.dart';
import 'story_cover.dart';

void showAppSnack(BuildContext context, String message,
    {String? actionLabel, VoidCallback? onAction}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
    ));
}

// ------------------------------------------------------- pop-up opsi story
enum StoryAction {
  read,
  info,
  share,
  remove,
  archive,
  unarchive,
  addToReadingList,
  addToOffline,
  removeFromOffline,
}

Future<StoryAction?> showStoryOptionsDialog(
    BuildContext context, LibraryStory story) {
  final options = <(StoryAction, String)>[
    (StoryAction.read, 'Read'),
    (StoryAction.info, 'Story Info'),
    (StoryAction.share, 'Share Story'),
    (StoryAction.remove, 'Remove From Library'),
    story.isArchived
        ? (StoryAction.unarchive, 'Unarchive Story')
        : (StoryAction.archive, 'Archive Story'),
    (StoryAction.addToReadingList, 'Add to Reading List'),
    story.isOffline
        ? (StoryAction.removeFromOffline, 'Remove From Offline List')
        : (StoryAction.addToOffline, 'Add to Offline List'),
  ];

  return showDialog<StoryAction>(
    context: context,
    barrierColor: const Color(0xB3000000),
    builder: (ctx) => Dialog(
      backgroundColor: LibColors.dialog,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Text(
                story.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            for (final (action, label) in options)
              InkWell(
                onTap: () => Navigator.pop(ctx, action),
                child: Container(
                  height: 48,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(label,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

// ------------------------------------------------------------- story info
void showStoryInfoSheet(BuildContext context, LibraryStory story) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 90,
              height: 140,
              child: StoryCover(
                  title: story.title,
                  author: story.author,
                  coverUrl: story.coverUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(story.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('by ${story.author}',
                      style: const TextStyle(color: LibColors.textSecondary)),
                  const SizedBox(height: 12),
                  Text(story.description ?? 'No description available.',
                      style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 12),
                  Text('Progress: ${(story.progress * 100).round()}%',
                      style: const TextStyle(color: LibColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ------------------------------------------------------------ dialog nama
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  String confirmLabel = 'Save',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) =>
        _NameDialog(title: title, initial: initial, confirmLabel: confirmLabel),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog(
      {required this.title, required this.initial, required this.confirmLabel});
  final String title;
  final String initial;
  final String confirmLabel;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _text =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: LibColors.dialog,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      title: Text(widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
      content: TextField(
        controller: _text,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Reading list name',
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: LibColors.orange)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('CANCEL', style: TextStyle(color: LibColors.orange)),
        ),
        TextButton(
          onPressed: () {
            final v = _text.text.trim();
            if (v.isNotEmpty) Navigator.pop(context, v);
          },
          child: Text(widget.confirmLabel.toUpperCase(),
              style: const TextStyle(color: LibColors.orange)),
        ),
      ],
    );
  }
}

// ------------------------------------------------- Add to Reading List
/// Dialog pilih reading list (toggle) atau buat baru.
/// [getLists] dibaca ulang setiap rebuild; [onToggle]/[onCreate] mengubah state
/// di LibraryScreen.
Future<void> showAddToReadingListDialog(
  BuildContext context, {
  required LibraryStory story,
  required List<LibraryReadingList> Function() getLists,
  required Future<void> Function(String listId) onToggle,
  required Future<void> Function(String name) onCreate,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialog) {
        final lists = getLists();
        return AlertDialog(
          backgroundColor: LibColors.dialog,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          title: const Text('Add to Reading List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          contentPadding: const EdgeInsets.only(top: 8),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.add, color: LibColors.orange),
                  title: const Text('New reading list'),
                  onTap: () async {
                    final name = await showNameDialog(ctx,
                        title: 'New reading list', confirmLabel: 'Create');
                    if (name == null) return;
                    await onCreate(name);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      showAppSnack(context, 'Added to "$name"');
                    }
                  },
                ),
                for (final l in lists)
                  ListTile(
                    title: Text(l.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        l.storyIds.length == 1
                            ? '1 story'
                            : '${l.storyIds.length} stories',
                        style: const TextStyle(color: LibColors.textSecondary)),
                    trailing: l.storyIds.contains(story.id)
                        ? const Icon(Icons.check, color: LibColors.orange)
                        : null,
                    onTap: () async {
                      await onToggle(l.id);
                      if (ctx.mounted) setDialog(() {});
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('DONE', style: TextStyle(color: LibColors.orange)),
            ),
          ],
        );
      },
    ),
  );
}

Future<String?> showPickReadingListDialog(
  BuildContext context, {
  required List<LibraryReadingList> lists,
  required Future<String> Function(String name) onCreate,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: LibColors.dialog,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      title: const Text('Add to Reading List',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
      contentPadding: const EdgeInsets.only(top: 8),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.add, color: LibColors.orange),
              title: const Text('New reading list'),
              onTap: () async {
                final name = await showNameDialog(ctx,
                    title: 'New reading list', confirmLabel: 'Create');
                if (name == null) return;
                final id = await onCreate(name);
                if (ctx.mounted) Navigator.pop(ctx, id);
              },
            ),
            for (final l in lists)
              ListTile(
                title:
                    Text(l.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                    l.storyIds.length == 1
                        ? '1 story'
                        : '${l.storyIds.length} stories',
                    style: const TextStyle(color: LibColors.textSecondary)),
                onTap: () => Navigator.pop(ctx, l.id),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child:
              const Text('CANCEL', style: TextStyle(color: LibColors.orange)),
        ),
      ],
    ),
  );
}
