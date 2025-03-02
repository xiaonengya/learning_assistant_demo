import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;
  final bool isLoading;
  final VoidCallback? onPresetButtonPressed;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.isLoading = false,
    this.onPresetButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // 预设按钮
          if (onPresetButtonPressed != null)
            IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: '预设文本',
              onPressed: onPresetButtonPressed,
            ),
          
          // 输入框
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              minLines: 1,
              maxLines: 5,
              enabled: !isLoading,
              textInputAction: TextInputAction.send,
              onSubmitted: isLoading ? null : onSubmit,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 发送按钮
          FloatingActionButton(
            onPressed: isLoading ? null : () => onSubmit(controller.text),
            tooltip: '发送',
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
