import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.isError = false,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: _getBubbleColor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: InkWell(
          onLongPress: () => _showOptions(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                message,
                style: TextStyle(
                  color: _getTextColor(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: _getTextColor(context).withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  if (isUser) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.person,
                      size: 12,
                      color: _getTextColor(context).withOpacity(0.6),
                    ),
                  ] else if (!isError) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.smart_toy,
                      size: 12,
                      color: _getTextColor(context).withOpacity(0.6),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBubbleColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isError) {
      return isDark ? Colors.red[900]! : Colors.red[100]!;
    }
    if (isUser) {
      return Theme.of(context).colorScheme.primaryContainer;
    }
    return isDark
        ? Theme.of(context).colorScheme.surfaceVariant
        : Theme.of(context).colorScheme.surfaceVariant;
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isError) {
      return isDark ? Colors.red[100]! : Colors.red[900]!;
    }
    if (isUser) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('复制文本'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: message));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
          ),
          if (!isUser)
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('保存为预设文本'),
              onTap: () {
                Navigator.pop(context);
                _showSaveDialog(context);
              },
            ),
        ],
      ),
    );
  }
  
  void _showSaveDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存为预设文本'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '预设名称',
            hintText: '输入预设名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // TODO: 保存预设文本逻辑
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已保存预设文本"${controller.text}"')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
