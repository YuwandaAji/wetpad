import 'dart:async';

import 'package:flutter/foundation.dart';

class ProfileActionStore extends ChangeNotifier {
  ProfileActionStore._();

  static final ProfileActionStore instance = ProfileActionStore._();

  final Map<String, DateTime> _mutedUntil = {};
  final Map<String, Timer> _muteTimers = {};
  final Set<String> _permanentlyMutedProfiles = {};
  final Set<String> _blockedProfiles = {};
  final Set<String> _reportedProfiles = {};
  final Set<String> _reportedPosts = {};

  bool isMuted(String id) {
    if (_permanentlyMutedProfiles.contains(id)) return true;
    final mutedUntil = _mutedUntil[id];
    return mutedUntil != null && mutedUntil.isAfter(DateTime.now());
  }

  bool isBlocked(String id) => _blockedProfiles.contains(id);

  bool isPostReported(String id) => _reportedPosts.contains(id);

  bool isProfileReported(String id) => _reportedProfiles.contains(id);

  void mute(String id, Duration duration) {
    final mutedUntil = DateTime.now().add(duration);
    _mutedUntil[id] = mutedUntil;
    _muteTimers.remove(id)?.cancel();
    _muteTimers[id] = Timer(duration, () {
      if (_mutedUntil[id] != mutedUntil) return;
      _mutedUntil.remove(id);
      _muteTimers.remove(id);
      notifyListeners();
    });
    notifyListeners();
  }

  void muteProfile(String id) {
    _muteTimers.remove(id)?.cancel();
    _mutedUntil.remove(id);
    if (_permanentlyMutedProfiles.add(id)) notifyListeners();
  }

  void cancelMute(String id) {
    _muteTimers.remove(id)?.cancel();
    final hadTimedMute = _mutedUntil.remove(id) != null;
    final hadPermanentMute = _permanentlyMutedProfiles.remove(id);
    final changed = hadTimedMute || hadPermanentMute;
    if (changed) notifyListeners();
  }

  void reportPost(String id) {
    _reportedPosts.add(id);
    notifyListeners();
  }

  void reportProfile(String id) {
    _reportedProfiles.add(id);
    notifyListeners();
  }

  void blockProfile(String id) {
    if (_blockedProfiles.add(id)) notifyListeners();
  }

  void unblockProfile(String id) {
    if (_blockedProfiles.remove(id)) notifyListeners();
  }
}
