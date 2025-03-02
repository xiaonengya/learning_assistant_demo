import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/api_config/api_config_bloc.dart';
import '../../blocs/preset/preset_bloc.dart';
import '../../../domain/models/api_config.dart';
import '../../../domain/models/ai_role.dart';
import '../../widgets/chat/chat_message_list.dart';
import '../../widgets/common/loading_indicator.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 加载消息、配置和预设
    context.read<ChatBloc>().add(LoadMessagesEvent());
    context.read<ApiConfigBloc>().add(LoadApiConfigsEvent());
    context.read<PresetBloc>().add(LoadPresetsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is MessagesLoaded) {
              setState(() {
                _isLoading = state.isSending;
              });
            }
          },
        ),
        BlocListener<ApiConfigBloc, ApiConfigState>(
          listener: (context, state) {
            if (state is ApiConfigError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        BlocListener<PresetBloc, PresetState>(
          listener: (context, state) {
            if (state is PresetError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: Column(
        children: [
          // 状态栏 - 让其更加突出显示
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: _buildStatusBar(),
          ),
          
          // 消息列表
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const LoadingIndicator(message: '加载消息中...');
                } else if (state is MessagesLoaded) {
                  return ChatMessageList(messages: state.messages);
                } else {
                  return const Center(
                    child: Text('加载消息失败，请重试'),
                  );
                }
              },
            ),
          ),
          
          // 输入区域
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is MessagesLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                // API配置选择
                Expanded(
                  flex: 3,
                  child: _buildApiConfigSelector(
                    context,
                    state.currentConfig,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 角色选择
                Expanded(
                  flex: 3,
                  child: _buildRoleSelector(
                    context,
                    state.currentRole,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 清空按钮
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '清空对话',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.6),
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  onPressed: () => _confirmClearMessages(context),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildApiConfigSelector(
    BuildContext context,
    APIConfig? currentConfig,
  ) {
    return BlocBuilder<ApiConfigBloc, ApiConfigState>(
      builder: (context, state) {
        if (state is ApiConfigsLoaded) {
          bool isCurrentDefault = false;
          if (state.defaultConfig != null && currentConfig != null) {
            isCurrentDefault = currentConfig.id == state.defaultConfig!.id;
          }
          
          if (state.configs.isEmpty) {
            return OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('添加API配置'),
              onPressed: () {
                Navigator.pushNamed(context, '/api_configs');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }
          
          return PopupMenuButton<String>(
            tooltip: '选择API配置',
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 增加圆角
            ),
            padding: EdgeInsets.zero, // 减少内边距
            elevation: 4, // 增加阴影
            offset: const Offset(0, 8), // 调整偏移
            child: Container( // 修复了这里的语法错误，添加了左括号
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.api,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentConfig?.name ?? state.defaultConfig?.name ?? '选择API',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 显示收藏/默认标记
                  if (isCurrentDefault) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            onSelected: (configId) {
              // 处理非"管理"和"设为默认"的选项
              if (configId != 'manage' && configId != 'set_default') {
                final selectedConfig = state.configs.firstWhere(
                  (config) => config.id == configId,
                );
                
                if (context.read<ChatBloc>().state is MessagesLoaded) {
                  context.read<ChatBloc>().add(UpdateConfigEvent(selectedConfig));
                  // 如果有聊天记录，询问是否清空
                  _promptClearMessagesIfNeeded(context);
                }
              }
            },
            itemBuilder: (context) => [
              // 添加"设为默认"选项
              if (currentConfig != null && 
                  state.defaultConfig != null && 
                  currentConfig.id != state.defaultConfig!.id)
                PopupMenuItem<String>(
                  value: 'set_default',
                  padding: EdgeInsets.zero, // 减少内边距
                  height: 40, // 减少高度
                  child: ListTile(
                    leading: Icon(
                      Icons.star_border,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20, // 减小图标
                    ),
                    title: const Text('设为默认API配置'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    onTap: () {
                      Navigator.pop(context); // 先关闭菜单
                      context.read<ApiConfigBloc>().add(
                        SetDefaultApiConfigEvent(currentConfig.id),
                      );
                    },
                  ),
                ),
              
              // 分隔线
              if (currentConfig != null && 
                  state.defaultConfig != null && 
                  currentConfig.id != state.defaultConfig!.id)
                const PopupMenuDivider(height: 8),
                
              // 添加管理选项
              PopupMenuItem<String>(
                value: 'manage',
                padding: EdgeInsets.zero, // 减少内边距
                height: 40, // 减少高度
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20, // 减小图标
                  ),
                  title: const Text('管理API配置'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    Navigator.pop(context); // 先关闭菜单
                    Navigator.pushNamed(context, '/api_configs');
                  },
                ),
              ),
              
              const PopupMenuDivider(height: 8),
              
              // API配置列表标题
              PopupMenuItem<String>(
                enabled: false,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'API配置列表',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              
              // API配置列表 - 不变
              ...state.configs.map((config) {
                final isSelected = config.id == currentConfig?.id;
                final isDefaultConfig = config.id == state.defaultConfig?.id;
                return PopupMenuItem<String>(
                  value: config.id,
                  child: Row(
                    children: [
                      // 标记为"当前选中"
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                      if (isSelected) 
                        const SizedBox(width: 8),
                      
                      // 显示API信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  config.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                  ),
                                ),
                                // 标记为"默认"
                                if (isDefaultConfig) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              config.model,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }
        return const Text('加载API配置中...');
      },
    );
  }
  
  Widget _buildRoleSelector(
    BuildContext context,
    AIRole? currentRole,
  ) {
    return BlocBuilder<PresetBloc, PresetState>(
      builder: (context, state) {
        if (state is PresetsLoaded) {
          bool isCurrentDefault = false;
          if (state.defaultRole != null && currentRole != null) {
            isCurrentDefault = currentRole.id == state.defaultRole!.id;
          }
          
          if (state.roles.isEmpty) {
            return OutlinedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('添加角色'),
              onPressed: () {
                // 导航到角色管理页面
                Navigator.pushNamed(context, '/roles');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            );
          }
          
          return PopupMenuButton<String>(
            tooltip: '选择AI角色',
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 增加圆角
            ),
            padding: EdgeInsets.zero, // 减少内边距
            elevation: 4, // 增加阴影
            offset: const Offset(0, 8), // 调整偏移
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 18,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentRole?.name ?? state.defaultRole?.name ?? '选择角色',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 显示收藏/默认标记
                  if (isCurrentDefault) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
            onSelected: (roleId) {
              // 处理非"管理"和"设为默认"的选项
              if (roleId != 'manage' && roleId != 'set_default') {
                final selectedRole = state.roles.firstWhere(
                  (role) => role.id == roleId,
                );
                
                if (context.read<ChatBloc>().state is MessagesLoaded) {
                  context.read<ChatBloc>().add(UpdateRoleEvent(selectedRole));
                }
              }
            },
            itemBuilder: (context) => [
              // 添加"设为默认"选项 - 样式和功能与API配置选择器相似
              if (currentRole != null && 
                  state.defaultRole != null && 
                  currentRole.id != state.defaultRole!.id)
                PopupMenuItem<String>(
                  value: 'set_default',
                  padding: EdgeInsets.zero, // 减少内边距
                  height: 40, // 减少高度
                  child: ListTile(
                    leading: Icon(
                      Icons.star_border,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20, // 减小图标
                    ),
                    title: const Text('设为默认角色'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    onTap: () {
                      Navigator.pop(context); // 先关闭菜单
                      context.read<PresetBloc>().add(
                        SetDefaultRoleEvent(currentRole.id),
                      );
                    },
                  ),
                ),
              
              // 分隔线
              if (currentRole != null && 
                  state.defaultRole != null && 
                  currentRole.id != state.defaultRole!.id)
                const PopupMenuDivider(height: 8),
              
              // 添加管理选项
              PopupMenuItem<String>(
                value: 'manage',
                padding: EdgeInsets.zero, // 减少内边距
                height: 40, // 减少高度
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20, // 减小图标
                  ),
                  title: const Text('管理AI角色'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    Navigator.pop(context); // 先关闭菜单
                    Navigator.pushNamed(context, '/roles');
                  },
                ),
              ),
              
              const PopupMenuDivider(height: 8),
              
              // 角色列表标题  
              PopupMenuItem<String>(
                enabled: false,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'AI角色列表',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
                
              // 角色列表 - 不变
              ...state.roles.map((role) {
                final isSelected = role.id == currentRole?.id;
                final isDefaultRole = role.id == state.defaultRole?.id;
                return PopupMenuItem<String>(
                  value: role.id,
                  child: Row(
                    children: [
                      // 标记为"当前选中"
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 16,
                        ),
                      if (isSelected) 
                        const SizedBox(width: 8),
                        
                      // 显示角色信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  role.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Theme.of(context).colorScheme.secondary : null,
                                  ),
                                ),
                                // 标记为"默认"
                                if (isDefaultRole) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              role.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }
        return const Text('加载角色中...');
      },
    );
  }
  
  void _confirmClearMessages(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有聊天记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ChatBloc>().add(ClearMessagesEvent());
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  void _promptClearMessagesIfNeeded(BuildContext context) {
    final state = context.read<ChatBloc>().state;
    if (state is MessagesLoaded && state.messages.isNotEmpty) {
      _confirmClearMessages(context);
    }
  }
  
  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // 输入框
          Expanded(
            child: TextField(
              controller: _messageController,
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
              enabled: !_isLoading,
              textInputAction: TextInputAction.send,
              onSubmitted: _isLoading ? null : _sendMessage,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 发送按钮
          FloatingActionButton(
            onPressed: _isLoading ? null : () => _sendMessage(_messageController.text),
            tooltip: '发送',
            child: _isLoading
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
  
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    final state = context.read<ChatBloc>().state;
    if (state is MessagesLoaded) {
      context.read<ChatBloc>().add(SendMessageEvent(
        text,
        apiConfig: state.currentConfig,
        role: state.currentRole,
      ));
      _messageController.clear();
    }
  }
}