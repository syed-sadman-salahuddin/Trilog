import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

// Follow Requests Screen (equivalent to RequestFrag)
class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final uid = currentUser?.userId ?? '';

    if (uid.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final requestsAsync = ref.watch(followRequestsProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Follow Requests')),
      body: requestsAsync.when(
        data: (requestUids) => requestUids.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search_rounded,
                        size: 64, color: AppTheme.textGray),
                    SizedBox(height: 12),
                    Text('No follow requests',
                        style: TextStyle(color: AppTheme.textGray)),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: requestUids.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppTheme.divider),
                itemBuilder: (ctx, i) {
                  final requesterUid = requestUids[i];
                  final userAsync =
                      ref.watch(userByIdProvider(requesterUid));
                  return ListTile(
                    leading: userAsync.when(
                      data: (u) => CircleAvatar(
                        backgroundImage: u?.profile != null
                            ? CachedNetworkImageProvider(u!.profile!)
                            : null,
                        backgroundColor: AppTheme.shimmerBase,
                        child: u?.profile == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      loading: () => const CircleAvatar(
                          backgroundColor: AppTheme.shimmerBase),
                      error: (_, __) => const CircleAvatar(
                          backgroundColor: AppTheme.shimmerBase),
                    ),
                    title: Text(
                        userAsync.valueOrNull?.name ?? 'Loading...',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        userAsync.valueOrNull?.profession ?? '',
                        style: const TextStyle(
                            color: AppTheme.textGray, fontSize: 13)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Accept
                        IconButton(
                          icon: const Icon(Icons.check_circle_rounded,
                              color: AppTheme.primary),
                          onPressed: () async {
                            await ref
                                .read(dbServiceProvider)
                                .acceptFollowRequest(uid, requesterUid);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Request accepted')));
                            }
                          },
                        ),
                        // Reject
                        IconButton(
                          icon: const Icon(Icons.cancel_rounded,
                              color: AppTheme.accent),
                          onPressed: () async {
                            await ref
                                .read(dbServiceProvider)
                                .rejectFollowRequest(uid, requesterUid);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
