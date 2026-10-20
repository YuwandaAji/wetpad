import 'package:flutter/material.dart';

import '../models/community.dart';
import '../models/feed_item.dart';
import '../models/profile.dart';
import '../models/story.dart';
import 'communities_data.dart';
import 'stories_data.dart';
import 'profile_store.dart';

class ProfilesData {
  static List<Story> _storiesBy(String name) => StoriesData.all
      .where((s) => s.author.toLowerCase() == name.toLowerCase())
      .toList();

  static Profile? _meOverride;
  static set me(Profile p) => _meOverride = p;

  /// Profil akun kita sendiri, diambil dari ProfileStore.
  static Profile get me {
    if (_meOverride != null) return _meOverride!;
    final s = ProfileStore.instance;
    return Profile(
      id: 'me',
      type: ProfileType.user,
      name: s.name,
      username: s.username,
      about: s.about,
      followers: 0,
      following: 0,
      color: const Color(0xFF14171C),
      bannerColor: const Color(0xFF666666), // abu-abu seperti di screenshot
      isMe: true,
      image: s.avatarImage,
      joinedLabel: 'Bergabung sejak 15 Okt',
      stories: const [StoriesData.draft],
      readingLists: [
        ProfileReadingList(
          title: 'Daftar Bacaan ${s.username}',
          stories: const [StoriesData.midnightLetters],
        ),
      ],
    );
  }

  static List<Profile> _followingSample({required String except}) =>
      CommunitiesData.all
          .where((c) => c.id != except)
          .take(5)
          .map((c) => fromCommunity(c, deep: false))
          .toList();

  static List<Profile> _followerSample() => const [
    'PaperHearts',
    'NightOwl',
    'EmberWrites',
    'RavenQuill',
    'MirrorInk',
  ].map((name) => writer(name, deep: false)).toList();

  static Profile fromCommunity(Community c, {bool deep = true}) => Profile(
    id: c.id,
    type: ProfileType.community,
    name: c.name,
    username: c.name,
    about: c.description.isEmpty
        ? 'Komunitas ${c.name} di Wattpad.'
        : c.description,
    followers: c.members,
    following: 10 + c.members % 60,
    color: c.color,
    textColor: c.textColor,
    bannerColor: const Color(0xFF555555),
    isOfficial: true,
    stories: _storiesBy(c.name),
    readingListsTotal: 3 + c.members % 9,
    readingLists: deep
        ? const [
            ProfileReadingList(
              title: 'Dark Academia',
              stories: [
                StoriesData.duplicity,
                StoriesData.midnightLetters,
                StoriesData.whisperHouse,
              ],
            ),
          ]
        : const [],
    followingProfiles: deep ? _followingSample(except: c.id) : const [],
    followerProfiles: _followerSample(),
  );

  static Profile writer(String name, {bool deep = true}) {
    final seed = name.codeUnits.fold<int>(0, (a, b) => a + b);
    const palette = [
      Color(0xFF3B4A8C),
      Color(0xFF2E5E4E),
      Color(0xFFB4410B),
      Color(0xFF5B2A86),
      Color(0xFFD6336C),
    ];
    return Profile(
      id: 'writer_$name',
      type: ProfileType.writer,
      name: name,
      username: name,
      about: 'I pop in occasionally, but will not be active on here anymore (find me on ao3 instead under the same username). Thank you for reading my stories and for all the support so far!',
      followers: 500 + seed * 7,
      following: 20 + seed % 80,
      color: palette[seed % palette.length],
      bannerColor: const Color(0xFF4A4A4A),
      stories: _storiesBy(name),
      readingListsTotal: 2 + seed % 6,
      readingLists: deep
          ? const [
              ProfileReadingList(
                title: 'Bacaan Favorit',
                stories: [StoriesData.fireKing, StoriesData.hollowCrown],
              ),
            ]
          : const [],
      followingProfiles: deep ? _followingSample(except: '') : const [],
    );
  }

  /// Nama penulis di kartu cerita -> komunitas bila namanya sama, selain itu penulis.
  static Profile forAuthor(String name) {
    final i = CommunitiesData.all.indexWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
    );
    return i >= 0 ? fromCommunity(CommunitiesData.all[i]) : writer(name);
  }

  /// Cari profil dari id yang tersimpan di FollowStore.
  static Profile? byId(String id) {
    if (id == 'me') return me;
    final i = CommunitiesData.all.indexWhere((c) => c.id == id);
    if (i >= 0) return fromCommunity(CommunitiesData.all[i], deep: false);
    if (id.startsWith('writer_')) {
      return writer(id.substring(7), deep: false);
    }
    return null;
  }

  /// Kartu feed otomatis untuk penulis yang diikuti.
  static List<FeedItem> generatedFeed(Iterable<String> ids) {
    final out = <FeedItem>[];
    for (final id in ids) {
      if (!id.startsWith('writer_')) continue;
      final p = writer(id.substring(7), deep: false);
      if (p.stories.isEmpty) continue;
      out.add(
        FeedItem(
          id: 'gen_$id',
          community: Community(
            id: p.id,
            name: p.name,
            description: '',
            members: p.followers,
            color: p.color,
            textColor: p.textColor,
          ),
          type: FeedItemType.readingListAdded,
          minutesAgo: 20 + (p.name.length * 13) % 300,
          storyCount: p.stories.length,
          title: 'Cerita oleh ${p.name}',
          subtitle: '${p.stories.length} cerita',
          stories: p.stories,
        ),
      );
    }
    return out;
  }
}
