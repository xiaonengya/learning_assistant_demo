import 'package:flutter/material.dart';
import '../services/api_config_service.dart';
import '../models/api_config.dart';
import '../services/chat_service.dart';
import '../models/ai_preset_text.dart';
import '../services/ai_preset_text_service.dart';
import '../pages/unified_preset_page.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final APIConfigService _configService = APIConfigService();
  final ChatService _chatService = ChatService();
  APIConfig? _currentConfig;
  AIPresetText? _currentPreset;
  bool _isLoading = false;
  List<AIPresetText> _presets = []; // 添加预设列表

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _loadPreset();
    _loadAllPresets(); // 加载所有预设
    _checkFirstUse();
  }

  Future<void> _checkFirstUse() async {
    try {
      final configs = await _configService.loadConfigs();
      if (configs.isEmpty && mounted) {
        // 如果没有任何配置,显示引导对话框
        showDialog(
          context: context,
          barrierDismissible: false, // 防止用户点击外部关闭
          builder: (context) => AlertDialog(
            title: const Text('欢迎使用'),
            content: const Text('检测到您还没有设置API配置,需要先添加配置才能开始对话。是否现在前往设置？'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 跳转到预设管理页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnifiedPresetPage(),
                    ),
                  );
                },
                child: const Text('去设置'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('检查首次使用失败: $e');
    }
  }

  Future<void> _loadConfig() async {
    _currentConfig = await _configService.getDefaultConfig();
    if (_currentConfig == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置API设置')),
      );
    }
  }

  Future<void> _loadPreset() async {
    try {
      final presetService = AIPresetTextService();
      _currentPreset = await presetService.getDefaultPreset();
    } catch (e) {
      print('加载预设失败: $e');
    }
  }

  Future<void> _loadAllPresets() async {
    try {
      final presetService = AIPresetTextService();
      _presets = await presetService.loadPresets();
      setState(() {});
    } catch (e) {
      print('加载预设列表失败: $e');
    }
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty) return;

    // 发送前检查配置
    if (_currentConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先设置API配置'),
          action: SnackBarAction(
            label: '去设置',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UnifiedPresetPage(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    // 如果有预设，添加到消息开头
    final message =
        _currentPreset != null ? '${_currentPreset!.content}\n\n$text' : text;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
    );

    setState(() {
      _isLoading = true;
      _messages.insert(0, userMessage);
    });

    _messageController.clear();

    try {
      final response = await _chatService.sendMessage(
        message: message,
        config: _currentConfig!,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.insert(
              0,
              ChatMessage(
                text: response,
                isUser: false,
              ));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 修改顶部布局
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // 顶部对齐
            children: [
              // 预设选择卡片
              Expanded(
                child: Card(
                  elevation: 2,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12), // 增加内边距
                    title: Row(
                      children: [
                        Icon(
                          _currentPreset?.isDefault ?? false
                              ? Icons.star
                              : Icons.chat_bubble_outline,
                          size: 28, // 增大图标
                          color: _currentPreset?.isDefault ?? false
                              ? Colors.amber
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16), // 增大间距
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentPreset?.name ?? '通用预设',
                                style: const TextStyle(
                                  fontSize: 18, // 增大字号
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_currentPreset != null)
                                Text(
                                  _currentPreset!.content,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium, // 调整副标题样式
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    iconColor: Theme.of(context).colorScheme.primary, // 折叠图标颜色
                    collapsedIconColor: Theme.of(context).colorScheme.primary,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12), // 增加垂直内边距
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.3),
                          border: Border(
                            top: BorderSide(
                                color: Theme.of(context).dividerColor),
                            bottom: BorderSide(
                                color: Theme.of(context).dividerColor),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24), // 增加水平内边距
                          leading: Icon(
                            Icons.chat_bubble_outline,
                            size: 28, // 增大图标
                            color: _currentPreset == null
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          title: const Text(
                            '通用预设',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          trailing: _currentPreset == null
                              ? Icon(
                                  Icons.check_circle,
                                  size: 28,
                                  color: Colors.green.shade400,
                                )
                              : null,
                          selected: _currentPreset == null,
                          onTap: () => setState(() => _currentPreset = null),
                        ),
                      ),
                      if (_presets.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Text(
                                '预设列表',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context).dividerColor,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: _presets.length,
                          itemBuilder: (context, index) => ListTile(
                            leading: Icon(
                              _presets[index].isDefault
                                  ? Icons.star
                                  : Icons.chat_bubble_outline,
                              color: _currentPreset?.id == _presets[index].id
                                  ? Theme.of(context).colorScheme.primary
                                  : _presets[index].isDefault
                                      ? Colors.amber
                                      : null,
                            ),
                            title: Text(_presets[index].name),
                            subtitle: Text(
                              _presets[index].content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            selected: _currentPreset?.id == _presets[index].id,
                            trailing: _currentPreset?.id == _presets[index].id
                                ? Icon(
                                    Icons.check_circle,
                                    size: 28,
                                    color: Colors.green.shade400,
                                  )
                                : null,
                            onTap: () => setState(
                                () => _currentPreset = _presets[index]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // 右侧操作区
              const SizedBox(width: 8), // 间距
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // 改为左对齐
                children: [
                  // 新建对话按钮
                  FilledButton.icon(
                    onPressed: _newChat,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('新建对话'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, // 减少水平内边距
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // 按钮与文本之间的间距
                  // 消息数量显示
                  Row(
                    // 使用Row来布局文字和数字
                    children: [
                      const Text(
                        '当前消息:',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4), // 文字和数字之间的间距
                      Text(
                        _messages.length.toString(),
                        style: TextStyle(
                          fontSize: 15, // 增大数字字号
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(8.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _messages[index],
          ),
        ),
        if (_isLoading) const LinearProgressIndicator(),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12, // 减少水平内边距
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "输入消息...",
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    // ...existing border styles...
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12, // 增加垂直内边距
                    ),
                  ),
                  style: const TextStyle(fontSize: 15),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _handleSubmitted,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => _handleSubmitted(_messageController.text),
                tooltip: '发送',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 添加新建对话方法
  Future<void> _newChat() async {
    try {
      // 显示确认对话框
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('新建对话'),
          content: const Text('开始新对话将清除当前的对话记录,是否继续?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认'),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        // 清除消息列表
        setState(() {
          _messages.clear();
        });

        // 清理旧对话存储
        await _chatService.clearHistory();

        // 显示提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已开始新对话')),
          );
        }
      }
    } catch (e) {
      print('新建对话失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('新建对话失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.assistant, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
