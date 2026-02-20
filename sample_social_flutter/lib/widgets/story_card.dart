import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class StoryCard extends ConsumerWidget {
  final StoryModel story;
  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(story.storyBy ?? ''));

    return GestureDetector(
      onTap: () => _openStory(context, story),
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(2.5),
              child: userAsync.when(
                data: (user) => CircleAvatar(
                  backgroundImage: user?.profile != null
                      ? CachedNetworkImageProvider(user!.profile!)
                      : null,
                  backgroundColor: AppTheme.shimmerBase,
                  child: user?.profile == null
                      ? const Icon(Icons.person,
                          color: Colors.white, size: 28)
                      : null,
                ),
                loading: () => const CircleAvatar(
                    backgroundColor: AppTheme.shimmerBase),
                error: (_, __) =>
                    const CircleAvatar(backgroundColor: AppTheme.shimmerBase),
              ),
            ),
            const SizedBox(height: 6),
            userAsync.when(
              data: (user) => Text(
                user?.name.split(' ').first ?? '',
                style: const TextStyle(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              loading: () => Container(
                  height: 10, width: 40, color: AppTheme.shimmerBase),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _openStory(BuildContext context, StoryModel story) {
    if (story.stories.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: PageView.builder(
          itemCount: story.stories.length,
          itemBuilder: (_, i) {
            final s = story.stories[i];
            return Container(
              color: Colors.black,
              child: s.storyUrl != null
                  ? CachedNetworkImage(
                      imageUrl: s.storyUrl!,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.error, color: Colors.white),
                    )
                  : const Icon(Icons.image_not_supported,
                      color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}
