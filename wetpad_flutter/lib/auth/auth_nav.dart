import 'package:flutter/material.dart';

import '../home/screens/home_screen.dart';

void goHome(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (_) => false,
  );
}
