import 'package:flutter/material.dart';

import '../models/story.dart';

class StoriesData {
  static const raiseAssassin = Story(
    id: 's1', title: 'How to Raise an Assassin', author: 'BronxCrusader',
    reads: 632, parts: 49, stars: 41,
    tags: ['action', 'crime', 'drama', 'thriller'],
    coverColor: Color(0xFF14171C), coverText: 'HOW TO RAISE AN ASSASSIN',
  );
  static const virusWithin = Story(
    id: 's2', title: 'The Virus Within', author: 'CrystalScherer',
    reads: 1200, parts: 32, stars: 88,
    tags: ['scifi', 'survival', 'zombie'],
    coverColor: Color(0xFF7A1A2A), coverText: 'THE VIRUS WITHIN',
  );
  static const duplicity = Story(
    id: 's3', title: 'Duplicity', author: 'MirrorInk',
    reads: 8400, parts: 61, stars: 520,
    tags: ['mystery', 'identity', 'romance'],
    coverColor: Color(0xFF0B0B0B), coverText: 'DUPLICITY',
  );
  static const fireKing = Story(
    id: 's4', title: 'Fire King', author: 'EmberWrites',
    reads: 15300, parts: 40, stars: 910,
    tags: ['fantasy', 'royalty', 'enemies'],
    coverColor: Color(0xFFB4410B), coverText: 'FIRE KING',
  );
  static const halloween = Story(
    id: 's5', title: 'Halloween Vault 2026', author: 'Ambassadors',
    reads: 9800, parts: 12, stars: 300,
    tags: ['horror', 'event'],
    coverColor: Color(0xFFFF7A3D), coverText: 'Halloween Vault 2026',
  );
  static const midnightLetters = Story(
    id: 's6', title: 'Midnight Letters', author: 'PaperHearts',
    reads: 22100, parts: 27, stars: 1400,
    tags: ['romance', 'slowburn', 'drama'],
    coverColor: Color(0xFF3B4A8C), coverText: 'MIDNIGHT LETTERS',
  );
  static const hollowCrown = Story(
    id: 's7', title: 'The Hollow Crown', author: 'RavenQuill',
    reads: 5400, parts: 55, stars: 260,
    tags: ['fantasy', 'magic', 'war'],
    coverColor: Color(0xFF2E5E4E), coverText: 'THE HOLLOW CROWN',
  );
  static const whisperHouse = Story(
    id: 's8', title: 'Whisper House', author: 'NightOwl',
    reads: 31000, parts: 18, stars: 2100,
    tags: ['horror', 'ghost', 'mystery'],
    coverColor: Color(0xFF3A2145), coverText: 'WHISPER HOUSE',
  );

  // --- cerita milik komunitas "mystery" ---
  static const mysteryGuide = Story(
    id: 's9', title: 'Mystery Guide', author: 'mystery',
    reads: 15800, parts: 5, stars: 522,
    tags: ['knowhow'],
    description:
        'Welcome to the Mystery profile! This guide explains all the features of the community.',
    rankLabel: '# 21 – knowhow',
    coverColor: Color(0xFF3E4A5C), coverText: 'Mystery Guide',
  );
  static const intrigue = Story(
    id: 's10', title: 'Ink & Intrigue', author: 'mystery',
    reads: 9200, parts: 8, stars: 310,
    tags: ['challenge'],
    description: 'Monthly prompt challenge for mystery and thriller writers.',
    rankLabel: '# 54 – challenge',
    coverColor: Color(0xFF2F3B4A), coverText: 'Ink & Intrigue',
  );
  static const whodunit = Story(
    id: 's11', title: 'Whodunit Weekly', author: 'mystery',
    reads: 4100, parts: 12, stars: 150,
    tags: ['whodunit'],
    description: 'A new short whodunit every week. Can you guess the culprit?',
    coverColor: Color(0xFF4D5B6E), coverText: 'Whodunit Weekly',
  );

  // --- cerita milik penulis "Didget404" ---
  static const ourBond = Story(
    id: 's12', title: 'Our Bond (discontinued)', author: 'Didget404',
    reads: 25600, parts: 27, stars: 1150,
    tags: ['fanfiction', 'angst'],
    description:
        'DISCONTINUED. Haunted by his past, Izuku Midoriya is finally running.',
    rankLabel: '# 275 – nightmares',
    coverColor: Color(0xFF000000), coverText: 'OUR BOND',
  );
  static const neonVeins = Story(
    id: 's13', title: 'Neon Veins', author: 'Didget404',
    reads: 12400, parts: 18, stars: 640,
    tags: ['scifi', 'crime'],
    description: 'A neon-lit city, a missing brother and a debt to pay.',
    coverColor: Color(0xFF0B3D3A), coverText: 'NEON VEINS',
  );
  static const redHood = Story(
    id: 's14', title: 'Red Hood Chronicles', author: 'Didget404',
    reads: 8800, parts: 22, stars: 410,
    tags: ['fanfiction', 'action'],
    description: 'Short tales from the alleys of Gotham.',
    coverColor: Color(0xFF7A1A1A), coverText: 'RED HOOD',
  );

  // --- draft milik akun kita (belum terbit: parts = 0) ---
  static const draft = Story(
    id: 's15', title: 'Judul Standar - Tulis Judul Sendiri', author: 'sencroma',
    reads: 0, parts: 0, stars: 0,
    tags: [],
    coverColor: Color(0xFF2A2A2A), coverText: 'Judul Standar - Tulis Judul Sendiri',
  );

  static const all = [
    raiseAssassin, virusWithin, duplicity, fireKing, halloween,
    midnightLetters, hollowCrown, whisperHouse,
    mysteryGuide, intrigue, whodunit,
    ourBond, neonVeins, redHood,
    draft,
  ];
}