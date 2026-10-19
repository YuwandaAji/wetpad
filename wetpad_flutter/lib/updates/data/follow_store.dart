import 'package:flutter/foundation.dart';

/// Satu sumber kebenaran untuk status follow (komunitas, penulis, user).
/// Nanti diganti dengan panggilan API.
class FollowStore extends ChangeNotifier {
  FollowStore._();
  static final FollowStore instance = FollowStore._();

  final Set<String> _ids = {};
  bool _seeded = false;

  Set<String> get ids => Set.unmodifiable(_ids);
  bool isFollowing(String id) => _ids.contains(id);

  /// Dipanggil sekali untuk data awal.
  void seed(Iterable<String> initial) {
    if (_seeded) return;
    _seeded = true;
    _ids.addAll(initial);
  }

  void toggle(String id) {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
  }

  void setFollowing(String id, bool isFollowing) {
    final changed = isFollowing ? _ids.add(id) : _ids.remove(id);
    if (changed) notifyListeners();
  }
}
