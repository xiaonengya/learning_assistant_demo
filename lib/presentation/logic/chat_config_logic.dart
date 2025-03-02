import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/api_config/api_config_bloc.dart';
import '../blocs/preset/preset_bloc.dart';

/*
 * AI 对话配置切换逻辑说明
 *
 * API 配置切换逻辑:
 * 1. 用户在对话设置中选择不同的 API 配置时，应提示用户清空对话记录
 * 2. 用户选择的 API 配置会在当前会话和应用重启后一直保持，不会自动恢复到默认值
 * 3. API 配置切换通常需要清空对话，因为不同 API 可能有不同的上下文限制和能力
 *
 * AI 角色切换逻辑:
 * 1. 用户在对话设置中选择不同的 AI 角色时，不需要提示清空对话记录，可以无缝切换
 * 2. 应用重启后，AI 角色会恢复到默认设置
 * 3. 这是因为 AI 角色主要是设置 system prompt，可以在不清空对话的情况下即时更改 AI 行为
 */

/// 处理 API 配置切换
class ApiConfigSwitchHandler {
  /// 切换 API 配置
  /// 
  /// 如果 [showClearPrompt] 为 true，会显示提示用户清空对话的对话框
  /// 如果用户确认清空，返回 true；如果用户取消，返回 false
  static Future<bool> switchApiConfig({
    required BuildContext context,
    required String configId,
    bool showClearPrompt = true,
  }) async {
    final apiConfigBloc = context.read<ApiConfigBloc>();
    final chatBloc = context.read<ChatBloc>();
    
    if (apiConfigBloc.state is! ApiConfigsLoaded) return false;
    
    final configState = apiConfigBloc.state as ApiConfigsLoaded;
    final selectedConfig = configState.configs.firstWhere(
      (config) => config.id == configId,
      orElse: () => configState.configs.first,
    );
    
    // 是否需要提示用户清空对话
    if (showClearPrompt && chatBloc.state is MessagesLoaded) {
      final messages = (chatBloc.state as MessagesLoaded).messages;
      
      if (messages.isNotEmpty) {
        // 询问用户是否清空对话
        final shouldClear = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('切换 API 配置'),
            content: const Text('切换 API 配置可能导致对话出现问题，建议清空当前对话。\n\n是否现在清空对话？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('保留对话'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('清空对话'),
              ),
            ],
          ),
        ) ?? false;
        
        if (shouldClear) {
          chatBloc.add(ClearMessagesEvent());
        }
      }
    }
    
    // 切换 API 配置
    chatBloc.add(UpdateConfigEvent(selectedConfig));
    
    // 保存用户选择的 API 配置
    // 这将确保应用重启后仍使用用户选择的配置
    // 实际保存操作在 ApiConfigBloc 的 UpdateConfigEvent 处理中进行
    
    return true;
  }
}

/// 处理 AI 角色切换
class RoleSwitchHandler {
  /// 切换 AI 角色
  /// 
  /// 角色切换不需要清空对话，可以即时更改 AI 行为
  static void switchRole({
    required BuildContext context,
    required String roleId,
  }) {
    final presetBloc = context.read<PresetBloc>();
    final chatBloc = context.read<ChatBloc>();
    
    if (presetBloc.state is! PresetsLoaded) return;
    
    final presetState = presetBloc.state as PresetsLoaded;
    final selectedRole = presetState.roles.firstWhere(
      (role) => role.id == roleId,
      orElse: () => presetState.defaultRole!,
    );
    
    // 切换角色
    chatBloc.add(UpdateRoleEvent(selectedRole));
    
    // 注意：我们不保存用户选择的角色为永久设置
    // 应用重启后，将恢复使用默认角色
    // 这是设计决定，让用户每次启动应用都始于一个一致的角色体验
  }
  
  /// 恢复默认 AI 角色
  static void restoreDefaultRole({
    required BuildContext context,
  }) {
    final presetBloc = context.read<PresetBloc>();
    final chatBloc = context.read<ChatBloc>();
    
    if (presetBloc.state is! PresetsLoaded) return;
    
    final presetState = presetBloc.state as PresetsLoaded;
    if (presetState.defaultRole == null) return;
    
    // 恢复默认角色
    chatBloc.add(UpdateRoleEvent(presetState.defaultRole!));
  }
}

/// 应用启动时的配置恢复逻辑
class ConfigurationRestoreHandler {
  /// 应用启动时恢复配置
  static void restoreConfigurations(BuildContext context) {
    // 加载保存的 API 配置 - 将使用上次用户选择的配置
    context.read<ApiConfigBloc>().add(LoadApiConfigsEvent());
    
    // 加载 AI 角色配置 - 启动时会使用默认角色
    context.read<PresetBloc>().add(LoadPresetsEvent());
    
    // 加载消息历史并应用配置
    final chatBloc = context.read<ChatBloc>();
    chatBloc.add(LoadMessagesEvent());
    
    // 注意：ChatBloc 的 LoadMessagesEvent 处理器会在加载消息后
    // 自动应用默认或用户上次选择的 API 配置和默认角色
  }
}
