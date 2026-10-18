import 'package:flutter/material.dart';

import 'search_style.dart';

/// Kolom pencarian. Border berubah teal saat fokus.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final active = focusNode.hasFocus;
        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: SearchColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? SearchColors.teal : SearchColors.border,
              width: active ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            textInputAction: TextInputAction.search,
            cursorColor: SearchColors.teal,
            style: SearchText.input,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              hintText: active ? 'Search' : 'Search for stories or people',
              hintStyle: SearchText.hint,
              prefixIcon: const Icon(Icons.search,
                  color: SearchColors.textSecondary, size: 22),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, v, __) => v.text.isEmpty
                    ? const SizedBox.shrink()
                    : GestureDetector(
                        onTap: () {
                          controller.clear();
                          onChanged('');
                        },
                        child: const Icon(Icons.close,
                            color: SearchColors.textSecondary, size: 18),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
