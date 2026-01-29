import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';

final storageRepositoryProvider = Provider((ref) => StorageRepository());

class StorageRepository {
  // DIAGNOSTIC: REMOVED FIREBASE
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadStoryImage(File file) async {
    return "https://mock.url/story.jpg";
  }

  Future<String?> uploadAvatar(File file) async {
    return "https://mock.url/avatar.jpg";
  }
}
