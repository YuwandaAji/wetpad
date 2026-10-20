import 'package:flutter/material.dart';

import 'story.dart';

enum ProfileType { user, writer, community }

enum ProfileTab { about, conversation }

extension ProfileTabLabel on ProfileTab {
  String get label => this == ProfileTab.about ? 'TENTANG' : 'PERCAKAPAN';
}

class ProfileReadingList {
  final String title;
  final List<Story> stories;
  const ProfileReadingList({required this.title, required this.stories});
}

/// Satu model untuk user, penulis, dan komunitas.
class Profile {
    factory Profile.fromJson(Map<String, dynamic> j) {
    final name = j['username'] as String;
    final seed = name.codeUnits.fold<int>(0, (a, b) => a + b);
    const palette = [
      Color(0xFF3B4A8C), Color(0xFF2E5E4E), Color(0xFFB4410B),
      Color(0xFF5B2A86), Color(0xFFD6336C),
    ];
    final color = palette[seed % palette.length];

    Story toStory(Map<String, dynamic> s) => Story(
          id: '${s['id']}',
          title: s['title'] as String,
          author: name,
          reads: (s['reads_total'] ?? 0) as int,
          parts: (s['parts_count'] ?? 0) as int,
          stars: (s['stars_total'] ?? 0) as int,
          tags: List<String>.from(s['tags'] ?? const []),
          description: (s['description'] ?? '') as String,
          coverColor: color,
          coverText: s['title'] as String,
        );

    final stories = [
      for (final s in (j['stories'] as List)) toStory(Map<String, dynamic>.from(s)),
    ];
    final joined = j['joined_at'] == null
        ? null
        : DateTime.tryParse(j['joined_at'] as String)?.toLocal();
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];

    return Profile(
      id: 'user_$name',
      type: stories.any((s) => s.parts > 0) ? ProfileType.writer : ProfileType.user,
      name: name,
      username: name,
      about: (j['about'] ?? '') as String,
      followers: (j['followers_count'] ?? 0) as int,
      following: (j['following_count'] ?? 0) as int,
      color: color,
      bannerColor: const Color(0xFF1C1C1C),
      isMe: j['is_me'] == true,
      joinedLabel: joined == null
          ? ''
          : 'Bergabung sejak ${joined.day} ${months[joined.month - 1]}',
      stories: stories,
      readingLists: [
        for (final l in (j['reading_lists'] as List))
          ProfileReadingList(
            title: l['name'] as String,
            stories: [
              for (final s in (l['stories'] as List))
                Story(
                  id: '${s['id']}',
                  title: s['title'] as String,
                  author: '',
                  reads: 0,
                  parts: 1,
                  tags: const [],
                  coverColor: color,
                  coverText: s['title'] as String,
                ),
            ],
          ),
      ],
    );
  }
  final String id;
  final ProfileType type;
  final String name;
  final String username;
  final String about;
  final int followers;
  final int following;
  final Color color; // warna avatar
  final Color textColor;
  final Color bannerColor; // warna header
  final bool isOfficial; // badge centang + hati (komunitas)
  final bool isMe; // profil sendiri: koin + gerigi, tanpa tombol ikuti
  final ImageProvider? image; // <- ADD: foto profil (null = huruf inisial)
  final String joinedLabel;
  final List<Story> stories;
  final List<ProfileReadingList> readingLists;
  final int? readingListsTotal;
  final List<Profile> followingProfiles;
  final List<Profile> followerProfiles;

  const Profile({
    required this.id,
    required this.type,
    required this.name,
    required this.username,
    required this.about,
    required this.followers,
    this.following = 0,
    required this.color,
    this.textColor = Colors.white,
    this.bannerColor = const Color(0xFF1C1C1C),
    this.isOfficial = false,
    this.isMe = false,
    this.image, // <- ADD
    this.joinedLabel = '',
    this.stories = const [],
    this.readingLists = const [],
    this.readingListsTotal,
    this.followingProfiles = const [],
    this.followerProfiles = const [],
  });

  int get publishedCount => stories.where((s) => s.parts > 0).length;
  int get readingListCount => readingListsTotal ?? readingLists.length;

  List<ProfileTab> get tabs => const [
    ProfileTab.about,
    ProfileTab.conversation,
  ];
}