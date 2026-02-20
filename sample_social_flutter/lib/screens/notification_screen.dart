import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final uid = currentUser?.userId ?? '';

    if (uid.isEmpty) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final notifAsync = ref.watch(notificationsProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifAsync.when(
        data: (notifications) => notifications.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 64, color: AppTheme.textGray),
                    SizedBox(height: 12),
                    Text('No notifications yet',
                        style: TextStyle(color: AppTheme.textGray)),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppTheme.divider),
                itemBuilder: (ctx, i) {
                  final notif = notifications[i];
                  final userAsync = ref
                      .watch(userByIdProvider(notif.notifyBy ?? ''));
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
                            text: userAsync.valueOrNull?.name ??
                                'Someone',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          TextSpan(
                            text: _notifText(notif.notifyType),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      timeago.format(DateTime.fromMillisecondsSinceEpoch(
                          notif.notifiedAt)),
                      style: const TextStyle(
                          color: AppTheme.textGray, fontSize: 12),
                    ),
                    trailing: _notifIcon(notif.notifyType),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _notifText(String type) {
    switch (type) {
      case 'like':
        return ' liked your post';
      case 'comment':
        return ' commented on your post';
      case 'follow':
        return ' started following you';
      default:
        return ' interacted with you';
    }
  }

  Widget _notifIcon(String type) {
    switch (type) {
      case 'like':
        return const Icon(Icons.favorite_rounded, color: Colors.red, size: 20);
      case 'comment':
        return const Icon(Icons.chat_bubble_rounded,
            color: AppTheme.primary, size: 20);
      case 'follow':
        return const Icon(Icons.person_add_rounded,
            color: AppTheme.accent, size: 20);
      default:
        return const Icon(Icons.notifications_rounded, size: 20);
    }
  }
}
