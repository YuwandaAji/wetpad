import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/profile.dart';
import 'profiles_data.dart';

/// Postingan per profil (di memori). Nanti diganti API.
class ConversationStore extends ChangeNotifier {
  ConversationStore._();
  static final ConversationStore instance = ConversationStore._();

  final Map<String, List<Post>> _byProfile = {};
  int _counter = 0;

  List<Post> postsFor(Profile p) =>
      _byProfile.putIfAbsent(p.id, () => _seed(p));

  void addPost(Profile p, String text) {
    final me = ProfilesData.me;
    postsFor(p).insert(
      0,
      Post(
        id: 'p${_counter++}',
        authorId: me.id,
        authorName: me.name,
        authorColor: me.color,
        text: text,
        minutesAgo: 0,
      ),
    );
    notifyListeners();
  }

  void addReply(Post post, String text) {
    final me = ProfilesData.me;
    post.replies.add(
      Post(
        id: 'r${_counter++}',
        authorId: me.id,
        authorName: me.name,
        authorColor: me.color,
        text: text,
        minutesAgo: 0,
      ),
    );
    notifyListeners();
  }

  void deletePost(Profile profile, Post post) {
    final posts = postsFor(profile);
    final initialCount = posts.length;
    posts.removeWhere((item) => item.id == post.id);
    if (posts.length != initialCount) {
      notifyListeners();
    }
  }

  List<Post> _seed(Profile p) {
    if (p.isMe) return [];
    return [
      Post(
        id: 'seed_${p.id}_1',
        authorId: p.id,
        authorName: p.name, // profil itu sendiri yang memposting
        authorColor: p.color,
        text: 'Hello, everyone! 🎃\n\nThe wait is finally over! Something new is here this month, bringing a fresh series of prompts inspired by the spookiest time of the year. Join in and share what you write!',
        minutesAgo: 480,
        replies: [
          Post(
            id: 'seed_${p.id}_1a',
            authorId: 'user:paperhearts',
            authorName: 'PaperHearts',
            authorColor: const Color(0xFF3B4A8C),
            text: 'Can’t wait to join this one!',
            minutesAgo: 300,
          ),
        ],
      ),
      Post(
        id: 'seed_${p.id}_2',
        authorId: 'user:nightowl',
        authorName: 'NightOwl',
        authorColor: const Color(0xFF5B2A86),
        text: 'Selamat datang untuk anggota baru 👋',
        minutesAgo: 1300,
      ),
    ];
  }
}
