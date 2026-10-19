import 'package:flutter/material.dart';

import '../app/main_shell.dart';
import '../core/config_api.dart';
import 'pages/welcome_page.dart';

void goHome(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const MainShell()),
    (_) => false,
  );
}

Future<void> logout(BuildContext context) async {
  await Session.clear();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const WelcomePage()),
    (_) => false,
  );
}