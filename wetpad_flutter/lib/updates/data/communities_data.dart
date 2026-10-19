import 'package:flutter/material.dart';

import '../models/community.dart';

class CommunitiesData {
  static const vampire = Community(
    id: 'vampire',
    name: 'Vampire',
    description: 'Dark romance, immortal rivals and gothic tales.',
    members: 35700,
    color: Color(0xFFFCE7EE),
    textColor: Color(0xFFC2185B),
  );
  static const fanfic = Community(
    id: 'fanfic',
    name: 'Fanfic',
    description: 'Fanfics from your favourite fandoms.',
    members: 571300,
    color: Color(0xFF9DE8D2),
    textColor: Color(0xFFE85D75),
  );
  static const fandoms = Community(
    id: 'fandoms',
    name: 'Fandoms',
    description: 'Talk about the fandoms you love.',
    members: 15800,
    color: Color(0xFF0E6B78),
  );
  static const action = Community(
    id: 'action',
    name: 'action',
    description: 'Fast-paced stories, fights, chases and daring escapes.',
    members: 110400,
    color: Color(0xFF1C1C1C),
    textColor: Color(0xFFF5C518),
  );
  static const wattpad = Community(
    id: 'wattpad',
    name: 'Wattpad',
    description: 'Official news, picks and reading lists.',
    members: 2300000,
    color: Color(0xFFFF6122),
  );
  static const romance = Community(
    id: 'romance',
    name: 'Romance',
    description: 'Slow burns, enemies to lovers and more.',
    members: 96200,
    color: Color(0xFFD6336C),
  );
  static const fantasy = Community(
    id: 'fantasy',
    name: 'Fantasy',
    description: 'Dragons, magic systems and world-building.',
    members: 54100,
    color: Color(0xFF2F7D6B),
  );
  static const horror = Community(
    id: 'horror',
    name: 'Horror',
    description: 'Creepy reads and Halloween events.',
    members: 33800,
    color: Color(0xFF5B2A86),
  );
  static const scifi = Community(
    id: 'scifi',
    name: 'Sci-Fi',
    description: 'Space operas, dystopias and futures.',
    members: 21700,
    color: Color(0xFF1F5FBF),
  );
  static const mystery = Community(
    id: 'mystery',
    name: 'mystery',
    description: "Welcome to Mystery!\n\nThis is the official ambassador-run profile for the Mystery and Thriller community. From book recommendations to monthly writing challenges, there is something new for every sleuth to explore. Follow along, join the conversation and share your own theories.",
    members: 185000,
    color: Color(0xFF3E4A5C),
  );

  /// Owner of some reading lists (not recommendable).
  static const ambassadors = Community(
    id: 'ambassadors',
    name: 'AmbassadorsID',
    description: '',
    members: 0,
    color: Color(0xFF9DE8D2),
    textColor: Color(0xFF1E7B6E),
  );

  /// Recommendation order. The first 3 not-yet-followed are shown.
  static const all = [
    action,
    vampire,
    fanfic,
    fandoms,
    mystery,
    wattpad,
    romance,
    fantasy,
    horror,
    scifi,
  ];

  /// Nothing followed at first launch (matches the screenshot).
  static const initiallyFollowedIds = <String>{};
}
