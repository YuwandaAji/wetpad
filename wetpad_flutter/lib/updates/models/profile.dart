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
