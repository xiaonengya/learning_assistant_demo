import 'package:flutter/material.dart';
import '../../models/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(isUser: false),
          Flexible(child: _buildMessageContent(context)),
          if (message.isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        backgroundColor: isDark
            ? (isUser ? Colors.blue[800] : Colors.grey[800])
            : (isUser ? Colors.blue[100] : Colors.grey[200]),
        child: Icon(
          isUser ? Icons.person : Icons.android,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final bgColor = message.isUser
        ? (isDark ? Colors.blue[900] : Colors.blue[100])
        : message.isError
            ? (isDark ? Colors.red[900] : Colors.red[100])
            : (isDark ? Colors.grey[800] : Colors.grey[200]);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            message.text,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
