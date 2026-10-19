import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PostComposer extends StatefulWidget {
  final String hint;
  final String buttonLabel;
  final ValueChanged<String> onSubmit;
  final bool autofocus;
  final Color fillColor;

  const PostComposer({
    super.key,
    required this.hint,
    required this.onSubmit,
    this.buttonLabel = 'Posting',
    this.autofocus = false,
    this.fillColor = AppColors.tabBackground,
  });

  @override
  State<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final _controller = TextEditingController();

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  void _submit() {
    final text = _controller.text.trim();
    _controller.clear();
    widget.onSubmit(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            minLines: 1,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: widget.fillColor,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        TextButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(
            widget.buttonLabel,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _canSubmit ? AppColors.orange : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}