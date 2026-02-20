import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPostImage(File image, String uid) async {
    final ref = _storage
        .ref('posts/$uid/${DateTime.now().millisecondsSinceEpoch}');
    final task = await ref.putFile(image);
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadStoryImage(File image, String uid) async {
    final ref = _storage
        .ref('stories/$uid/${DateTime.now().millisecondsSinceEpoch}');
    final task = await ref.putFile(image);
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadProfileImage(File image, String uid) async {
    final ref = _storage.ref('profiles/$uid/profile');
    final task = await ref.putFile(image);
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadCoverImage(File image, String uid) async {
    final ref = _storage.ref('covers/$uid/cover');
    final task = await ref.putFile(image);
    return await task.ref.getDownloadURL();
  }
}
