import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../models/notification_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final dbServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.watch(dbServiceProvider).userStream(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final userByIdProvider =
    StreamProvider.family<UserModel?, String>((ref, uid) {
  return ref.watch(dbServiceProvider).userStream(uid);
});

final postsProvider = StreamProvider<List<PostModel>>((ref) {
  return ref.watch(dbServiceProvider).postsStream();
});

final storiesProvider = StreamProvider<List<StoryModel>>((ref) {
  return ref.watch(dbServiceProvider).storiesStream();
});

final notificationsProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, uid) {
  return ref.watch(dbServiceProvider).notificationsStream(uid);
});

final followingProvider =
    StreamProvider.family<List<String>, String>((ref, uid) {
  return ref.watch(dbServiceProvider).followingStream(uid);
});

final isFollowingProvider =
    FutureProvider.family<bool, ({String currentUid, String targetUid})>(
        (ref, args) {
  return ref
      .watch(dbServiceProvider)
      .isFollowing(args.currentUid, args.targetUid);
});

final followRequestsProvider =
    StreamProvider.family<List<String>, String>((ref, uid) {
  return ref.watch(dbServiceProvider).followRequestsStream(uid);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return const Stream.empty();
  return ref.watch(dbServiceProvider).searchUsers(query);
});
