import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../../data/chat_repository.dart';
import '../../domain/models/chat_message_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String targetUserId;
  final String targetName;
  final String targetAvatar;

  const ChatScreen({
    super.key,
    required this.targetUserId,
    required this.targetName,
    required this.targetAvatar,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    final repo = ref.read(chatRepositoryProvider);
    await repo.sendMessage(widget.targetUserId, text);
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeOut
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(chatRepositoryProvider);
    // MOCK USER ID
    final currentUserId = 'mock_user_id';

    // ... REMAINDER OF UI CODE IS SAME, JUST REMOVED FIREBASE IMPORT
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.targetAvatar),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.targetName, style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFCCFF00), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text("Online", style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: repo.getMessages(widget.targetUserId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFCCFF00)));

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                   return const Center(child: Text("Start the vibe... \uD83D\uDC4B", style: TextStyle(color: Colors.white54)));
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;
                    return _buildMessage(msg, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessageModel msg, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFCCFF00) : const Color(0xFF141416),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(msg.timestamp, locale: 'en_short'),
              style: TextStyle(color: isMe ? Colors.black54 : Colors.white24, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add, color: Color(0xFFCCFF00)), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFFCCFF00)), 
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
