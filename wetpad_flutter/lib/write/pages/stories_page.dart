import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../widgets/continue_writing_card.dart';
import 'add_story_info_page.dart';
import 'edit_story_page.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  void _newStory(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddStoryInfoPage()));
  }

  void _openStory(BuildContext context, WriteSummary story) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => EditStoryPage(initial: story)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: const Text(
            'Create',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => _newStory(context),
              child: const Text(
                'NEW STORY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: ColoredBox(
              color: kGreyField,
              child: TabBar(
                indicatorColor: kOrange,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'Published'),
                  Tab(text: 'Drafts'),
                ],
              ),
            ),
          ),
        ),
        body: ValueListenableBuilder<WriteSummary?>(
          valueListenable: writeSummary,
          builder: (context, story, _) {
            // TODO: ganti dengan daftar cerita dari API (write_repository)
            final published = <WriteSummary>[
              if (story != null && story.publishedParts > 0) story,
            ];
            final drafts = <WriteSummary>[
              if (story != null && story.publishedParts == 0) story,
            ];

            return TabBarView(
              children: [
                _StoryList(
                  stories: published,
                  emptyMessage: "You haven't published any stories yet",
                  buttonLabel: 'Publish a Story',
                  onNew: () => _newStory(context),
                  onOpen: (s) => _openStory(context, s),
                ),
                _StoryList(
                  stories: drafts,
                  emptyMessage: "You don't have any drafts yet",
                  buttonLabel: 'Start Writing',
                  onNew: () => _newStory(context),
                  onOpen: (s) => _openStory(context, s),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StoryList extends StatelessWidget {
  const _StoryList({
    required this.stories,
    required this.emptyMessage,
    required this.buttonLabel,
    required this.onNew,
    required this.onOpen,
  });

  final List<WriteSummary> stories;
  final String emptyMessage;
  final String buttonLabel;
  final VoidCallback onNew;
  final ValueChanged<WriteSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return _EmptyState(
        message: emptyMessage,
        buttonLabel: buttonLabel,
        onPressed: onNew,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: stories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) =>
          _StoryTile(story: stories[i], onTap: () => onOpen(stories[i])),
    );
  }
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.story, required this.onTap});

  final WriteSummary story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parts = story.publishedParts;
    final title = story.title.trim().isEmpty ? 'Untitled' : story.title;

    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 82,
            height: 126,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: kGreyField,
              borderRadius: BorderRadius.circular(4),
            ),
            child: story.coverBytes == null
                ? const Icon(Icons.image_outlined, color: Colors.grey)
                : Image.memory(story.coverBytes!, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$parts published part${parts == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                if (story.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    story.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 28),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
