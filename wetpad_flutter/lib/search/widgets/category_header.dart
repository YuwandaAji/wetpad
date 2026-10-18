import 'package:flutter/material.dart';

import '../data/search_models.dart';
import 'search_style.dart';

class CategoryHeader extends StatefulWidget {
  const CategoryHeader({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.expanded,
    required this.onSelect,
    required this.onToggle,
  });

  static const double collapsedHeight = 48;

  final List<SearchCategory> categories;
  final int selectedIndex;
  final bool expanded;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggle;

  @override
  State<CategoryHeader> createState() => _CategoryHeaderState();
}

class _CategoryHeaderState extends State<CategoryHeader> {
  late List<GlobalKey> _keys = _makeKeys();

  List<GlobalKey> _makeKeys() =>
      List.generate(widget.categories.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(covariant CategoryHeader old) {
    super.didUpdateWidget(old);
    if (old.categories.length != widget.categories.length) _keys = _makeKeys();
    final collapsedNow = old.expanded && !widget.expanded;
    if (old.selectedIndex != widget.selectedIndex || collapsedNow) {
      _revealSelected();
    }
  }

  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedIndex >= _keys.length) return;
      final ctx = _keys[widget.selectedIndex].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            alignment: 0.5, duration: const Duration(milliseconds: 250));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v > 150 && !widget.expanded) widget.onToggle();
        if (v < -150 && widget.expanded) widget.onToggle();
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: widget.expanded ? _panel(context) : _bar(),
      ),
    );
  }

  // ---- collapsed ---------------------------------------------------------
  Widget _bar() {
    return Container(
      height: CategoryHeader.collapsedHeight,
      decoration: const BoxDecoration(
        color: SearchColors.background,
        border: Border(bottom: BorderSide(color: SearchColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  for (var i = 0; i < widget.categories.length; i++) _tab(i),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Show all categories',
            onPressed: widget.onToggle,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _tab(int i) {
    final c = widget.categories[i];
    final selected = i == widget.selectedIndex;
    return GestureDetector(
      key: _keys[i],
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onSelect(i),
      child: Container(
        height: CategoryHeader.collapsedHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? SearchColors.accent : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (c.isOriginals) ...[
              const Text('W',
                  style: TextStyle(
                    color: SearchColors.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  )),
              const SizedBox(width: 5),
            ],
            Text(
              c.isOriginals ? 'Originals' : c.name,
              style: selected ? SearchText.tabSelected : SearchText.tab,
            ),
          ],
        ),
      ),
    );
  }

  // ---- expanded ----------------------------------------------------------
  Widget _panel(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.6;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 2, 16),
      decoration: const BoxDecoration(
        color: SearchColors.panel,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < widget.categories.length; i++) _chip(i),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Collapse',
            onPressed: widget.onToggle,
            icon: const Icon(Icons.keyboard_arrow_up,
                color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _chip(int i) {
    final selected = i == widget.selectedIndex;
    return GestureDetector(
      onTap: () => widget.onSelect(i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : SearchColors.panelChip,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.categories[i].name,
          style: SearchText.chip
              .copyWith(color: selected ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}
