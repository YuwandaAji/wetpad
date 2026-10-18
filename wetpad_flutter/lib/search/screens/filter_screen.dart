import 'package:flutter/material.dart';

import '../data/search_models.dart';
import '../widgets/search_style.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({
    super.key,
    required this.initial,
    required this.availableTags,
    required this.onChanged,
  });

  final StoryFilter initial;
  final List<String> availableTags;
  final ValueChanged<StoryFilter> onChanged;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late StoryFilter _filter = widget.initial;

  void _update(StoryFilter f) {
    setState(() => _filter = f);
    widget.onChanged(f);
  }

  void _toggleTag(String tag) {
    final next = {..._filter.tags};
    if (!next.remove(tag)) next.add(tag);
    _update(_filter.copyWith(tags: next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SearchColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            const Divider(height: 1, color: SearchColors.divider),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  const Text('Sort by', style: SearchText.label),
                  const SizedBox(height: 4),
                  _radio('Hot', StorySort.hot),
                  _radio('New', StorySort.newest),
                  const SizedBox(height: 28),
                  const Text('Refine by tags', style: SearchText.label),
                  const SizedBox(height: 12),
                  if (widget.availableTags.isEmpty)
                    const Text('No tags available.', style: SearchText.label)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in widget.availableTags) _tagChip(t),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 4),
          const Text('Filter', style: SearchText.screenTitle),
          const Spacer(),
          TextButton(
            onPressed: () => _update(const StoryFilter()),
            child: const Text('Reset', style: SearchText.body),
          ),
        ],
      ),
    );
  }

  Widget _radio(String label, StorySort value) {
    final selected = _filter.sort == value;
    return InkWell(
      onTap: () => _update(_filter.copyWith(sort: value)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selected ? SearchColors.accent : const Color(0xFF555555),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: SearchColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: SearchText.body),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String tag) {
    final selected = _filter.tags.contains(tag);
    return GestureDetector(
      onTap: () => _toggleTag(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? SearchColors.tagSelectedBg : SearchColors.tagBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? SearchColors.accent : Colors.transparent,
          ),
        ),
        child: Text(
          tag,
          style: SearchText.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
