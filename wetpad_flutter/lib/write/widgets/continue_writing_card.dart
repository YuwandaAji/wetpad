import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Ringkasan cerita yang sedang ditulis. Disimpan di memori sementara,
/// nanti diganti dengan data dari API (write_repository).
class WriteSummary {
  const WriteSummary({
    required this.title,
    required this.description,
    required this.partTitles,
    this.coverBytes,
    this.language = 'English',
    this.storyType = '',
    this.tags = '',
    this.copyright = 'All Rights Reserved',
    this.mature = false,
    this.completed = false,
    this.drafts = 0,
  });

  final String title;
  final String description;
  final List<String> partTitles;
  final Uint8List? coverBytes;
  final String language;
  final String storyType;
  final String tags;
  final String copyright;
  final bool mature;
  final bool completed;
  final int drafts;

  int get publishedParts => partTitles.length;
}

final writeSummary = ValueNotifier<WriteSummary?>(null);

class ContinueWritingCard extends StatelessWidget {
  const ContinueWritingCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final WriteSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parts = summary.publishedParts;
    final drafts = summary.drafts;
    final title = summary.title.trim().isEmpty ? 'Untitled' : summary.title;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cover(),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Continue writing',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$parts published part${parts == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          '$drafts draft${drafts == 1 ? '' : 's'}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
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

  Widget _cover() {
    return Container(
      width: 98,
      height: 152,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kGreyField,
        borderRadius: BorderRadius.circular(4),
      ),
      child: summary.coverBytes == null
          ? const Icon(Icons.image_outlined, size: 32, color: Colors.grey)
          : Image.memory(summary.coverBytes!, fit: BoxFit.cover),
    );
  }
}
