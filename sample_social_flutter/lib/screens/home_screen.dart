import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/story_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    final storiesAsync = ref.watch(storiesProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trilog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text('Stories',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                SizedBox(
                  height: 100,
                  child: storiesAsync.when(
                    data: (stories) => ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        _AddStoryButton(uid: currentUser?.userId ?? ''),
                        ...stories.map((s) => StoryCard(story: s)),
                      ],
                    ),
                    loading: () => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (_, __) => _shimmerStory(),
                    ),
                    error: (e, _) => Center(child: Text('$e')),
                  ),
                ),
                const Divider(height: 1, color: AppTheme.divider),
              ],
            ),
          ),
          postsAsync.when(
            data: (posts) => posts.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text('No posts yet.\nBe the first to post!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textGray)),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => PostCard(post: posts[i]),
                      childCount: posts.length,
                    ),
                  ),
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => _shimmerPost(),
                childCount: 4,
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerStory() {
    return Shimmer.fromColors(
      baseColor: AppTheme.shimmerBase,
      highlightColor: AppTheme.shimmerHighlight,
      child: Container(
        width: 72,
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _shimmerPost() {
    return Shimmer.fromColors(
      baseColor: AppTheme.shimmerBase,
      highlightColor: AppTheme.shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.white),
              title: Container(height: 12, color: Colors.white),
              subtitle: Container(height: 10, color: Colors.white),
            ),
            Container(height: 240, color: Colors.white),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AddStoryButton extends ConsumerWidget {
  final String uid;
  const _AddStoryButton({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final image = await _pickImage();
        if (image == null || uid.isEmpty) return;
        final loadingCtrl = showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        try {
          final url = await ref
              .read(storageServiceProvider)
              .uploadStoryImage(image, uid);
          final story = UserStoriesHelper(url: url, at: DateTime.now().millisecondsSinceEpoch);
          await ref.read(dbServiceProvider).addStory(
                uid,
                story,
              );
        } finally {
          if (context.mounted) Navigator.pop(context);
        }
      },
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
                color: AppTheme.primary.withOpacity(0.12),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppTheme.primary, size: 28),
            ),
            const SizedBox(height: 6),
            const Text('Add Story',
                style: TextStyle(fontSize: 10, color: AppTheme.textGray),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _pickImage() async {
    final image_picker_import = await _pickImageFromGallery();
    return image_picker_import;
  }

  Future<dynamic> _pickImageFromGallery() async {
    return null; // actual impl in add_post_screen.dart
  }
}

class UserStoriesHelper {
  final String url;
  final int at;
  UserStoriesHelper({required this.url, required this.at});
}
