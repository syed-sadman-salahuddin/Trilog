import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/comment_model.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  ConsumerState<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final _commentCtrl = TextEditingController();
  bool _sending = false;

  // Scoped provider for this post's comments
  late final commentsProvider = StreamProvider<List<CommentModel>>((ref) {
    return ref.watch(dbServiceProvider).commentsStream(widget.postId);
  });

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final uid = ref.read(authServiceProvider).currentUid;
    if (uid == null) return;

    setState(() => _sending = true);
    try {
      await ref.read(dbServiceProvider).addComment(
            widget.postId,
            CommentModel(
              commenter: uid,
              commentText: text,
              commentedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
      _commentCtrl.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: commentsAsync.when(
              data: (comments) => comments.isEmpty
                  ? const Center(
                      child: Text('No comments yet. Be the first!',
                          style: TextStyle(color: AppTheme.textGray)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppTheme.divider),
                      itemBuilder: (ctx, i) {
                        final comment = comments[i];
                        final userAsync = ref.watch(
                            userByIdProvider(comment.commenter ?? ''));
                        return ListTile(
                          leading: userAsync.when(
                            data: (u) => CircleAvatar(
                              backgroundImage: u?.profile != null
                                  ? CachedNetworkImageProvider(u!.profile!)
                                  : null,
                              backgroundColor: AppTheme.shimmerBase,
                              child: u?.profile == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            loading: () => const CircleAvatar(
                                backgroundColor: AppTheme.shimmerBase),
                            error: (_, __) => const CircleAvatar(
                                backgroundColor: AppTheme.shimmerBase),
                          ),
                          title: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(ctx).style,
                              children: [
                                TextSpan(
                                  text:
                                      '${userAsync.valueOrNull?.name ?? ''} ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                TextSpan(
                                  text: comment.commentText,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Text(
                            timeago.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    comment.commentedAt)),
                            style: const TextStyle(
                                color: AppTheme.textGray, fontSize: 12),
                          ),
                        );
                      },
                    ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          // Comment Input
          Container(
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: AppTheme.divider)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                IconButton(
                  icon: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded,
                          color: AppTheme.primary),
                  onPressed: _sending ? null : _sendComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
