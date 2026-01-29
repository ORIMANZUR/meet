// import 'package:firebase_auth/firebase_auth.dart';
import '../domain/models/chat_message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

class ChatRepository {
  // REMOVED FOR DIAGNOSTICS
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getChatId(String otherUserId) {
    // Mock implementation
    return "mock_chat_id";
  }

  Stream<List<ChatMessageModel>> getMessages(String otherUserId) {
    return Stream.value([]);
  }

  Future<void> sendMessage(String otherUserId, String text) async {
    return;
  }
}
