import 'package:flutter/material.dart';

import '../data/follow_store.dart';
import '../data/library_store.dart';
import '../data/profiles_data.dart';
import '../models/profile.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_story_card.dart';
import '../utils/formatters.dart';
import '../utils/share_helper.dart';   // <-- TAMBAH
import '../widgets/story_cover.dart';
import 'profile_page.dart';

enum ProfileStatsSection { stories, readingLists, followers }

class ProfileStatsPage extends StatelessWidget {
  final Profile profile;
  final ProfileStatsSection section;

  const ProfileStatsPage({
    super.key,
    required this.profile,
    required this.section,
  });

  String get _title => switch (section) {
    ProfileStatsSection.stories => 'Cerita oleh ${profile.name}',
    ProfileStatsSection.readingLists => 'Daftar Bacaan ${profile.name}',
    ProfileStatsSection.followers => 'Pengikut',
  };

  @override
  Widget build(BuildContext context) {
    if (section == ProfileStatsSection.followers) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(profile.name),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'PENGIKUT'),
                Tab(text: 'MENGIKUTI'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _profileList(profile.followerProfiles),
              _profileList(profile.followingProfiles),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: AnimatedBuilder(
        animation: LibraryStore.instance,
        builder: (context, _) => switch (section) {
          ProfileStatsSection.stories => _storiesBody(),
          ProfileStatsSection.readingLists => _readingListsBody(
            profile.isMe
                ? LibraryStore.instance.readingListsFor(profile)
                : profile.readingLists,
          ),
          ProfileStatsSection.followers => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _storiesBody() {
    if (profile.stories.isEmpty) {
      return const _EmptyProfileSection(label: 'Belum ada karya.');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: profile.stories.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 20, color: AppColors.border),
      itemBuilder: (context, index) => _StoryListItem(
        story: profile.stories[index],
        onAdd: () => _showAddToLibrary(context, profile.stories[index]),
        onShare: () => _shareStory(context, profile.stories[index]),
      ),
    );
  }

  Widget _readingListsBody(List<ProfileReadingList> readingLists) {
    if (readingLists.isEmpty) {
      return const _EmptyProfileSection(label: 'Belum ada daftar bacaan.');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: readingLists.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 20, color: AppColors.border),
      itemBuilder: (context, index) {
        final readingList = readingLists[index];
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            readingList.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Daftar Bacaan • ${readingList.stories.length} Cerita',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (readingList.stories.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Belum ada cerita dalam daftar bacaan ini.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                SizedBox(
                  height: 164,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: readingList.stories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (_, storyIndex) => ProfileStoryCard(
                      story: readingList.stories[storyIndex],
                      width: 340,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileList(List<Profile> profiles) {
    if (profiles.isEmpty) {
      return const _EmptyProfileSection(
        label: 'Belum ada akun untuk ditampilkan.',
      );
    }
    return ListView.separated(
      itemCount: profiles.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 88),
      itemBuilder: (context, index) {
        final account = profiles[index];
        return _FollowProfileRow(profile: account);
      },
    );
  }

    Future<void> _shareStory(BuildContext context, Story story) {
    return shareContent(
      context,
      text: '${story.title} oleh ${story.author}\n${storyShareLink(story.id)}',
      subject: story.title,
      copiedMessage: 'Tautan cerita disalin.',
    );
  }

  Future<void> _showAddToLibrary(BuildContext context, Story story) async {
    final userLists = LibraryStore.instance
        .readingListsFor(ProfilesData.me)
        .where((list) => list.title != 'Perpustakaan (Pribadi)')
        .toList();
    final choice = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Text(
                  'Tambahkan ke',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text('Perpustakaan (Pribadi)'),
                onTap: () => Navigator.pop(sheetContext, 'private'),
              ),
              for (final list in userLists)
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(list.title),
                  onTap: () =>
                      Navigator.pop(sheetContext, 'list:${list.title}'),
                ),
              ListTile(
                leading: const Icon(Icons.add, color: AppColors.orange),
                title: const Text(
                  'Buat Daftar Bacaan',
                  style: TextStyle(color: AppColors.orange),
                ),
                onTap: () => Navigator.pop(sheetContext, 'create'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    final store = LibraryStore.instance;
    if (choice == 'private') {
      final alreadyAdded = store.isInPrivateLibrary(story);
      store.addToPrivateLibrary(story);
      _showAddedMessage(context, alreadyAdded);
      return;
    }
    if (choice == 'create') {
      final title = await showDialog<String>(
        context: context,
        builder: (_) => const _CreateReadingListDialog(),
      );
      if (!context.mounted || title == null) return;
      final normalizedTitle = title.trim();
      if (normalizedTitle.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama daftar bacaan tidak boleh kosong.'),
          ),
        );
        return;
      }
      final alreadyAdded = store.isInReadingList(normalizedTitle, story);
      store.createReadingList(normalizedTitle, story);
      _showAddedMessage(context, alreadyAdded);
      return;
    }

    final listTitle = choice.substring('list:'.length);
    final alreadyAdded = store.isInReadingList(listTitle, story);
    store.addToReadingList(listTitle, story);
    _showAddedMessage(context, alreadyAdded);
  }

  void _showAddedMessage(BuildContext context, bool alreadyAdded) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyAdded
              ? 'Cerita ini sudah ada di daftar tersebut.'
              : 'Cerita ditambahkan ke profil sencroma.',
        ),
      ),
    );
  }
}

class _CreateReadingListDialog extends StatefulWidget {
  const _CreateReadingListDialog();

  @override
  State<_CreateReadingListDialog> createState() =>
      _CreateReadingListDialogState();
}

class _CreateReadingListDialogState extends State<_CreateReadingListDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat Daftar Bacaan'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nama daftar bacaan'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Buat'),
        ),
      ],
    );
  }
}

class _FollowProfileRow extends StatelessWidget {
  final Profile profile;

  const _FollowProfileRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    final followStore = FollowStore.instance;
    return AnimatedBuilder(
      animation: followStore,
      builder: (context, _) {
        final isFollowing = followStore.isFollowing(profile.id);
        return SizedBox(
          height: 78,
          child: Row(
            children: [
              const SizedBox(width: 20),
              InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => openProfile(context, profile),
                child: ProfileAvatar(profile: profile, size: 56),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: InkWell(
                  onTap: () => openProfile(context, profile),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        profile.type == ProfileType.community
                            ? 'Komunitas Wattpad'
                            : '@${profile.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: SizedBox(
                  width: 52,
                  height: 40,
                  child: OutlinedButton(
                    key: ValueKey('follow-${profile.id}'),
                    onPressed: () => followStore.toggle(profile.id),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: isFollowing
                          ? Colors.white
                          : AppColors.link,
                      backgroundColor: isFollowing
                          ? AppColors.link
                          : Colors.white,
                      side: const BorderSide(color: AppColors.link),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Icon(
                      isFollowing ? Icons.how_to_reg : Icons.person_add_alt_1,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoryListItem extends StatelessWidget {
  final Story story;
  final VoidCallback onAdd;
  final VoidCallback onShare;

  const _StoryListItem({
    required this.story,
    required this.onAdd,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final tags = story.tags;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoryCover(story: story, width: 92, height: 141),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      height: 32,
                      child: PopupMenuButton<String>(
                        key: ValueKey('story-menu-${story.id}'),
                        padding: EdgeInsets.zero,
                        tooltip: 'Opsi cerita',
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                        ),
                        onSelected: (action) {
                          if (action == 'add') onAdd();
                          if (action == 'share') onShare();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'add',
                            child: Text('Tambahkan...'),
                          ),
                          PopupMenuItem(value: 'share', child: Text('Bagikan')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    _StoryMetric(
                      icon: Icons.remove_red_eye_outlined,
                      value: idCompact(story.reads),
                    ),
                    _StoryMetric(
                      icon: Icons.star_border,
                      value: idCompact(story.stars),
                    ),
                    _StoryMetric(
                      icon: Icons.format_list_bulleted,
                      value: '${story.parts}',
                    ),
                  ],
                ),
                if (story.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    story.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.25,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      for (final tag in tags.take(3)) _StoryTag(tag: tag),
                      if (tags.length > 3)
                        _StoryTag(label: '+ ${tags.length - 3} lagi'),
                    ],
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

class _StoryTag extends StatelessWidget {
  final String? tag;
  final String? label;

  const _StoryTag({this.tag, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label ?? tag ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StoryMetric extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StoryMetric({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _EmptyProfileSection extends StatelessWidget {
  final String label;

  const _EmptyProfileSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
