import 'package:flutter/material.dart';

import '../data/conversation_store.dart';
import '../data/profile_action_store.dart';
import '../data/profiles_data.dart';
import '../models/profile.dart';
import '../pages/create_post_page.dart';
import '../theme/app_theme.dart';
import 'post_tile.dart';
import 'profile_avatar.dart';

class ConversationTab extends StatelessWidget {
  final Profile profile;
  final String? initialPostId;

  const ConversationTab({super.key, required this.profile, this.initialPostId});

  Future<void> _openComposePage(BuildContext context) async {
    final text = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => CreatePostPage(profile: profile)),
    );
    if (text != null && context.mounted) {
      ConversationStore.instance.addPost(profile, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ConversationStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: ProfileActionStore.instance,
          builder: (context, _) {
            final posts = store
                .postsFor(profile)
                .where(
                  (post) => !ProfileActionStore.instance.isMuted(post.authorId),
                )
                .toList();
            if (initialPostId != null) {
              posts.sort((a, b) {
                final aIsTarget = a.id == initialPostId;
                final bIsTarget = b.id == initialPostId;
                if (aIsTarget == bIsTarget) return 0;
                return aIsTarget ? -1 : 1;
              });
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Material(
                  color: AppColors.tabBackground,
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _openComposePage(context),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ProfileAvatar(profile: ProfilesData.me, size: 40),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Posting pesan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Belum ada percakapan. Jadilah yang pertama!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  for (final p in posts) ...[
                    PostTile(
                      key: ValueKey(p.id),
                      post: p,
                      authorId: p.authorId,
                      isMine: p.authorId == ProfilesData.me.id,
                      onReply: (text) => store.addReply(p, text),
                      onDelete: () => store.deletePost(profile, p),
                    ),
                    const SizedBox(height: 14),
                  ],
              ],
            );
          },
        );
      },
    );
  }
}
