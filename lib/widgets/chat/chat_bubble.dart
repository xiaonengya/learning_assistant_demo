import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;
  final bool isDark;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.isError = false,
    required this.timestamp,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: _getBubbleColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message,
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(timestamp),
              style: TextStyle(
                color: _getTextColor().withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBubbleColor() {
    if (isError) {
      return isDark ? Colors.red[900]! : Colors.red[100]!;
    }
    if (isUser) {
      return isDark ? Colors.blue[800]! : Colors.blue[100]!;
    }
    return isDark ? Colors.grey[800]! : Colors.grey[200]!;
  }

  Color _getTextColor() {
    if (isError) {
      return isDark ? Colors.red[100]! : Colors.red[900]!;
    }
    return isDark ? Colors.white : Colors.black87;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
