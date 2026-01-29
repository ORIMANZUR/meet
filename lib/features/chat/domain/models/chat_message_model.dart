class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // REMOVED FOR DIAGNOSTICS
  // factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) ...
  // Map<String, dynamic> toFirestore() ...
}
