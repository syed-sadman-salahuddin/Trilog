import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../screens/comment_screen.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorAsync = ref.watch(userByIdProvider(post.postedBy ?? ''));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      shape: const RoundedRectangleBorder(),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          authorAsync.when(
            data: (author) => _buildHeader(context, author),
            loading: () => const _ShimmerLine(height: 56),
            error: (_, __) => const SizedBox.shrink(),
          ),
          if (post.postImage != null && post.postImage!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: post.postImage!,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 300,
                color: AppTheme.shimmerBase,
              ),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border_rounded),
                  onPressed: () {
                    if (post.postId != null && currentUser?.userId != null) {
                      ref.read(dbServiceProvider).likePost(
                            post.postId!,
                            currentUser!.userId!,
                          );
                    }
                  },
                ),
                Text('${post.postLike}',
                    style: const TextStyle(color: AppTheme.textGray)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                CommentScreen(postId: post.postId ?? '')));
                  },
                ),
                Text('${post.commentCount}',
                    style: const TextStyle(color: AppTheme.textGray)),
              ],
            ),
          ),
          if (post.postDescription.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(post.postDescription,
                  style: const TextStyle(fontSize: 14)),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              timeago.format(DateTime.fromMillisecondsSinceEpoch(post.postedAt)),
              style: const TextStyle(
                  color: AppTheme.textGray, fontSize: 12),
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? author) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: author?.profile != null
            ? CachedNetworkImageProvider(author!.profile!)
            : null,
        backgroundColor: AppTheme.shimmerBase,
        child: author?.profile == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(author?.name ?? 'Unknown',
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(author?.profession ?? '',
          style:
              const TextStyle(color: AppTheme.textGray, fontSize: 12)),
      trailing: const Icon(Icons.more_horiz),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double height;
  const _ShimmerLine({required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: AppTheme.shimmerBase,
      margin: const EdgeInsets.all(8),
    );
  }
}
