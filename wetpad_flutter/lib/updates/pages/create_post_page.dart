import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_avatar.dart';
import '../data/profiles_data.dart';

class CreatePostPage extends StatefulWidget {
  final Profile profile;

  const CreatePostPage({super.key, required this.profile});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posting di ${widget.profile.name}'),
        actions: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final canSubmit = value.text.trim().isNotEmpty;
              return TextButton(
                onPressed: canSubmit ? _submit : null,
                child: Text(
                  'Posting',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: canSubmit
                        ? AppColors.orange
                        : AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatar(profile: ProfilesData.me, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Posting pesan di ${widget.profile.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: null,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Tulis sesuatu…',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
