import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../domain/models/chat_message.dart';

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;

  const ChatMessageList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '开始对话吧！',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('在下方输入框中发送消息'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      reverse: true,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageBubble(message: message);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.isUser;
    final bubbleColor = isUserMessage 
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceVariant;
    
    final textColor = isUserMessage 
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    // 限制气泡最大宽度，促进更早换行
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.65;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            CircleAvatar(
              child: Icon(
                Icons.smart_toy,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxBubbleWidth,
              ),
              child: GestureDetector(
                onLongPress: !isUserMessage 
                    ? () {
                        Clipboard.setData(ClipboardData(text: message.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('消息已复制到剪贴板'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    : null,
                child: _MessageContent(
                  message: message,
                  isUserMessage: isUserMessage,
                  bubbleColor: bubbleColor,
                  textColor: textColor,
                ),
              ),
            ),
          ),
          
          if (isUserMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageContent extends StatefulWidget {
  final ChatMessage message;
  final bool isUserMessage;
  final Color bubbleColor;
  final Color textColor;

  const _MessageContent({
    required this.message,
    required this.isUserMessage,
    required this.bubbleColor,
    required this.textColor,
  });

  @override
  State<_MessageContent> createState() => _MessageContentState();
}

class _MessageContentState extends State<_MessageContent> {
  // 用于获取文本内容的高度
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 气泡容器
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.message.isError
                ? Theme.of(context).colorScheme.errorContainer
                : widget.bubbleColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            key: _contentKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isUserMessage) ...[
                _buildUserMessageContent(),
              ] else if (widget.message.isError) ...[
                _buildErrorMessageContent(),
              ] else ...[
                _buildAIMessageContent(),
              ],
            ],
          ),
        ),
        
        // 修改：始终将复制按钮放在右上角，并且减小尺寸
        if (!widget.isUserMessage && !widget.message.isError) ...[
          Positioned(
            top: -4, // 顶部微调，使部分按钮超出气泡
            right: -4, // 右侧微调，使部分按钮超出气泡
            child: Material(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              shape: const CircleBorder(),
              elevation: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.message.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('消息已复制到剪贴板'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4), // 减小内边距
                  child: const Icon(
                    Icons.copy_outlined,
                    size: 12, // 减小图标尺寸
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUserMessageContent() {
    return SelectableText(
      widget.message.text,
      style: TextStyle(color: widget.textColor),
    );
  }

  Widget _buildErrorMessageContent() {
    return SelectableText(
      widget.message.text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }

  Widget _buildAIMessageContent() {
    return MarkdownBody(
      data: widget.message.text,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: widget.textColor,
          fontSize: 15,
          height: 1.4,
        ),
        h1: TextStyle(
          color: widget.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: widget.textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: widget.textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        code: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.surface,
          color: Theme.of(context).colorScheme.secondary,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        listBullet: TextStyle(color: widget.textColor),
      ),
      softLineBreak: true, // 软换行
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          // 处理链接点击
        }
      },
    );
  }
}
