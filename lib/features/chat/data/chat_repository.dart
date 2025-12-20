import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/models/chat_message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getChatId(String otherUserId) {
    final currentUserId = _auth.currentUser!.uid;
    // Sort IDs to ensure same chat ID for both users
    final ids = [currentUserId, otherUserId]..sort();
    return ids.join('_');
  }

  Stream<List<ChatMessageModel>> getMessages(String otherUserId) {
    final chatId = _getChatId(otherUserId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessageModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> sendMessage(String otherUserId, String text) async {
    final chatId = _getChatId(otherUserId);
    final currentUserId = _auth.currentUser!.uid;
    
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Optional: Update last message in the chat document itself for list view
    await _firestore.collection('chats').doc(chatId).set({
      'users': [currentUserId, otherUserId],
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
