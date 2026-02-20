import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class UserTile extends ConsumerWidget {
  final UserModel user;
  final String currentUid;

  const UserTile({super.key, required this.user, required this.currentUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowingAsync =
        ref.watch(isFollowingProvider((currentUid: currentUid, targetUid: user.userId ?? '')));
    final db = ref.read(dbServiceProvider);

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.profile != null
            ? CachedNetworkImageProvider(user.profile!)
            : null,
        backgroundColor: AppTheme.shimmerBase,
        child: user.profile == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(user.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(user.profession,
          style: const TextStyle(color: AppTheme.textGray, fontSize: 13)),
      trailing: isFollowingAsync.when(
        data: (isFollowing) => SizedBox(
          height: 34,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? Colors.white : AppTheme.primary,
              foregroundColor: isFollowing ? AppTheme.primary : Colors.white,
              side: isFollowing
                  ? const BorderSide(color: AppTheme.primary)
                  : BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
            ),
            onPressed: user.userId == null
                ? null
                : () async {
                    if (isFollowing) {
                      await db.unfollowUser(currentUid, user.userId!);
                    } else {
                      await db.followUser(currentUid, user.userId!);
                    }
                    ref.invalidate(isFollowingProvider);
                  },
            child: Text(isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
        loading: () => const SizedBox(
            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
