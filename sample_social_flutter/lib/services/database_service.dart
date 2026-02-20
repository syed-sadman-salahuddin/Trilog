import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/story_model.dart';
import '../models/notification_model.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Stream<UserModel?> userStream(String uid) {
    return _db.ref('Users/$uid').onValue.map((event) {
      if (event.snapshot.value == null) return null;
      return UserModel.fromMap(
          event.snapshot.value as Map<dynamic, dynamic>, id: uid);
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final snap = await _db.ref('Users/$uid').get();
    if (!snap.exists) return null;
    return UserModel.fromMap(snap.value as Map<dynamic, dynamic>, id: uid);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.ref('Users/$uid').update(data);
  }

  Stream<List<UserModel>> searchUsers(String query) {
    return _db.ref('Users').onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries
          .map((e) => UserModel.fromMap(e.value as Map<dynamic, dynamic>, id: e.key as String))
          .where((u) =>
              u.name.toLowerCase().contains(query.toLowerCase()) ||
              u.profession.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Stream<List<PostModel>> postsStream() {
    return _db.ref('posts').onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries
          .map((e) => PostModel.fromMap(e.value as Map<dynamic, dynamic>, id: e.key as String))
          .toList()
        ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
    });
  }

  Future<void> addPost(PostModel post) async {
    await _db.ref('posts').push().set(post.toMap());
  }

  Future<void> likePost(String postId, String uid) async {
    final ref = _db.ref('posts/$postId');
    final snap = await ref.get();
    if (!snap.exists) return;
    final post = PostModel.fromMap(snap.value as Map<dynamic, dynamic>, id: postId);
    await ref.update({'postLike': post.postLike + 1});
  }

  Stream<List<CommentModel>> commentsStream(String postId) {
    return _db.ref('posts/$postId/comments').onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries
          .map((e) => CommentModel.fromMap(e.value as Map<dynamic, dynamic>, id: e.key as String))
          .toList()
        ..sort((a, b) => b.commentedAt.compareTo(a.commentedAt));
    });
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    await _db.ref('posts/$postId/comments').push().set(comment.toMap());
    await _db.ref('posts/$postId').update({
      'commentCount': ServerValue.increment(1),
    });
  }

  Stream<List<StoryModel>> storiesStream() {
    return _db.ref('stories').onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries.map((e) {
        final data = e.value as Map<dynamic, dynamic>;
        final userStoriesMap =
            data['userStories'] as Map<dynamic, dynamic>? ?? {};
        final stories = userStoriesMap.values
            .map((s) =>
                UserStoriesModel.fromMap(s as Map<dynamic, dynamic>))
            .toList();
        return StoryModel(
          storyBy: e.key as String,
          storyAt: (data['postedBy'] ?? 0) as int,
          stories: stories,
        );
      }).toList();
    });
  }

  Future<void> addStory(String uid, UserStoriesModel story) async {
    await _db
        .ref('stories/$uid/postedBy')
        .set(story.storyAt);
    await _db
        .ref('stories/$uid/userStories')
        .push()
        .set(story.toMap());
  }

  Future<void> followUser(String currentUid, String targetUid) async {
    await _db.ref('following/$currentUid/$targetUid').set(true);
    await _db.ref('followers/$targetUid/$currentUid').set(true);
    await _db.ref('Users/$targetUid').update({
      'followerCount': ServerValue.increment(1),
    });
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    await _db.ref('following/$currentUid/$targetUid').remove();
    await _db.ref('followers/$targetUid/$currentUid').remove();
    await _db.ref('Users/$targetUid').update({
      'followerCount': ServerValue.increment(-1),
    });
  }

  Future<bool> isFollowing(String currentUid, String targetUid) async {
    final snap =
        await _db.ref('following/$currentUid/$targetUid').get();
    return snap.exists;
  }

  Stream<List<String>> followingStream(String uid) {
    return _db.ref('following/$uid').onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.keys.cast<String>().toList();
    });
  }

  Future<void> sendFollowRequest(String fromUid, String toUid) async {
    await _db.ref('followRequests/$toUid/$fromUid').set(true);
  }

  Stream<List<String>> followRequestsStream(String uid) {
    return _db.ref('followRequests/$uid').onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.keys.cast<String>().toList();
    });
  }

  Future<void> acceptFollowRequest(String currentUid, String requesterUid) async {
    await _db.ref('followRequests/$currentUid/$requesterUid').remove();
    await followUser(requesterUid, currentUid);
  }

  Future<void> rejectFollowRequest(String currentUid, String requesterUid) async {
    await _db.ref('followRequests/$currentUid/$requesterUid').remove();
  }

  Stream<List<NotificationModel>> notificationsStream(String uid) {
    return _db.ref('notifications/$uid').onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries
          .map((e) => NotificationModel.fromMap(
              e.value as Map<dynamic, dynamic>, id: e.key as String))
          .toList()
        ..sort((a, b) => b.notifiedAt.compareTo(a.notifiedAt));
    });
  }

  Future<void> sendNotification(String targetUid, NotificationModel notif) async {
    await _db.ref('notifications/$targetUid').push().set(notif.toMap());
  }
}
