import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/profile.dart';
import '../services/profile_api.dart';
import 'profiles_data.dart';

/// Posts per profile. User/writer profiles come from the database,
/// community profiles stay local (mock).
class ConversationStore extends ChangeNotifier {
  ConversationStore._();
  static final ConversationStore instance = ConversationStore._();

  final Map<String, List<Post>> _byProfile = {};
  int _counter = 0;

  bool _remote(Profile p) => p.type != ProfileType.community;

  List<Post> postsFor(Profile p) =>
      _byProfile.putIfAbsent(p.id, () => _remote(p) ? [] : _seed(p));

  Future<void> load(Profile p) async {
    if (!_remote(p)) return;
    try {
      _byProfile[p.id] = await ProfileApi.posts(p);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addPost(Profile p, String text) async {
    if (_remote(p)) {
      await ProfileApi.createPost(p, text);
      return load(p);
    }
    final me = ProfilesData.me;
    postsFor(p).insert(
      0,
      Post(id: 'p${_counter++}', authorId: me.id, authorName: me.name,
          authorColor: me.color, text: text, minutesAgo: 0),
    );
    notifyListeners();
  }

  Future<void> addReply(Profile p, Post post, String text) async {
    if (_remote(p)) {
      await ProfileApi.createPost(p, text, parentId: post.id);
      return load(p);
    }
    final me = ProfilesData.me;
    post.replies.add(
      Post(id: 'r${_counter++}', authorId: me.id, authorName: me.name,
          authorColor: me.color, text: text, minutesAgo: 0),
    );
    notifyListeners();
  }

  Future<void> deletePost(Profile p, Post post) async {
    if (_remote(p)) {
      await ProfileApi.deletePost(post.id);
      return load(p);
    }
    final posts = postsFor(p);
    final n = posts.length;
    posts.removeWhere((x) => x.id == post.id);
    if (posts.length != n) notifyListeners();
  }

  List<Post> _seed(Profile p) {
    if (p.isMe) return [];
    return [
      Post(
        id: 'seed_${p.id}_1',
        authorId: p.id,
        authorName: p.name,
        authorColor: p.color,
        text: 'Hello, everyone! 🎃\n\nSomething new is here this month. Join in and share what you write!',
        minutesAgo: 480,
      ),
    ];
  }
}