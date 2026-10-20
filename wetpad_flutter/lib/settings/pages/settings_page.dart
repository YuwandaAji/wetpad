import 'package:flutter/material.dart';

import '../../core/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
      ),
      body: ListView(
        children: [
          _SettingsTile(title: 'Profile & account', onTap: () {}),
          _SettingsTile(title: 'Notifications', onTap: () {}),
          _SettingsTile(title: 'Reading preferences', onTap: () {}),
          _SettingsTile(title: 'Dark mode', subtitle: 'Auto', onTap: () {}),

          const _SectionHeader('PRIVACY & SAFETY'),
          _SettingsTile(title: 'Content preferences', onTap: () {}),
          _SettingsTile(title: 'Muted accounts', onTap: () {}),
          _SettingsTile(title: 'Blocked accounts', onTap: () {}),

          const _SectionHeader('SUBSCRIPTIONS'),
          _SettingsTile(title: 'Premium subscription', onTap: () {}),
          _SettingsTile(title: 'Customize theme', onTap: () {}),

          const _SectionHeader('PREFERRED STORIES'),
          _SettingsTile(
            title: 'Story language',
            subtitle: 'English',
            onTap: () {},
          ),

          const _SectionHeader('OTHER'),
          _SettingsTile(title: 'About Wetpad', onTap: () {}),
          _SettingsTile(title: 'Help & support', onTap: () {}),

          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              // TODO: logout
            },
            child: Container(
              color: kBg,
              padding: const EdgeInsets.symmetric(vertical: 22),
              alignment: Alignment.center,
              child: const Text(
                'Log out',
                style: TextStyle(
                  color: kOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Container(
            color: kBg,
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            alignment: Alignment.center,
            child: const Text(
              '© 2026 Wetpad',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kGreyField,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
          ],
        ),
      ),
    );
  }
}
