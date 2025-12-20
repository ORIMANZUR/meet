import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final storageRepositoryProvider = Provider((ref) => StorageRepository());

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadStoryImage(File file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('users/${user.uid}/story.jpg');
      
      // Upload task
      await ref.putFile(file);
      
      // Get URL
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      // In a real app we'd handle errors better
      return null;
    }
  }

  Future<String?> uploadAvatar(File file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('users/${user.uid}/avatar.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
