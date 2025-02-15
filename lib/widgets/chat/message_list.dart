import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import 'chat_bubble.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isDark;

  const MessageList({
    super.key,
    required this.messages,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              '开始对话吧',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(
          message: message.text,
          isUser: message.isUser,
          isError: message.isError,
          timestamp: message.timestamp,
          isDark: isDark,
        );
      },
    );
  }
}
