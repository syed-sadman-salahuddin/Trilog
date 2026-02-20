import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/user_tile.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final results = ref.watch(searchUsersProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or profession...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () =>
                            ref.read(searchQueryProvider.notifier).state = '',
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: query.trim().isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded,
                            size: 64, color: AppTheme.textGray),
                        SizedBox(height: 12),
                        Text('Search for people',
                            style: TextStyle(color: AppTheme.textGray)),
                      ],
                    ),
                  )
                : results.when(
                    data: (users) => users.isEmpty
                        ? const Center(
                            child: Text('No users found',
                                style:
                                    TextStyle(color: AppTheme.textGray)))
                        : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (_, i) => UserTile(
                                user: users[i],
                                currentUid: currentUser?.userId ?? ''),
                          ),
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Error: $e')),
                  ),
          ),
        ],
      ),
    );
  }
}
