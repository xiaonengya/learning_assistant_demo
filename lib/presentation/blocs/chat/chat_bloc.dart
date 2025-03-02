import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/models/chat_message.dart';
import '../../../domain/models/api_config.dart';
import '../../../domain/models/ai_role.dart';
import '../../../domain/models/ai_preset_text.dart';
import '../../../domain/usecases/chat_usecases.dart';
import '../../../domain/usecases/api_config_usecases.dart';
import '../../../domain/usecases/preset_usecases.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String text;
  final APIConfig? apiConfig; // 可选参数，如果不提供则使用默认配置
  final AIRole? role; // 可选参数，如果不提供则使用默认角色

  const SendMessageEvent(
    this.text, {
    this.apiConfig,
    this.role,
  });

  @override
  List<Object?> get props => [text, apiConfig, role];
}

class UpdateConfigEvent extends ChatEvent {
  final APIConfig config;

  const UpdateConfigEvent(this.config);

  @override
  List<Object> get props => [config];
}

class UpdateRoleEvent extends ChatEvent {
  final AIRole role;

  const UpdateRoleEvent(this.role);

  @override
  List<Object> get props => [role];
}

class ClearMessagesEvent extends ChatEvent {}

// States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class MessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  final APIConfig? currentConfig;
  final AIRole? currentRole;
  final AIPresetText? currentPresetText;
  final bool isSending;

  const MessagesLoaded({
    required this.messages,
    this.currentConfig,
    this.currentRole,
    this.currentPresetText,
    this.isSending = false,
  });

  MessagesLoaded copyWith({
    List<ChatMessage>? messages,
    APIConfig? currentConfig,
    AIRole? currentRole,
    AIPresetText? currentPresetText,
    bool? isSending,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      currentConfig: currentConfig ?? this.currentConfig,
      currentRole: currentRole ?? this.currentRole,
      currentPresetText: currentPresetText ?? this.currentPresetText,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        currentConfig,
        currentRole,
        currentPresetText,
        isSending,
      ];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final ClearConversation clearConversation;
  final SaveMessages saveMessages;
  final GetDefaultApiConfig? getDefaultApiConfig;
  final GetDefaultRole? getDefaultRole;
  final GetDefaultPresetText? getDefaultPresetText;
  final GetLastUsedApiConfig? getLastUsedApiConfig;
  final SaveLastUsedApiConfig? saveLastUsedApiConfig;

  ChatBloc({
    required this.getMessages,
    required this.sendMessage,
    required this.clearConversation,
    required this.saveMessages,
    this.getDefaultApiConfig,
    this.getDefaultRole,
    this.getDefaultPresetText,
    this.getLastUsedApiConfig,
    this.saveLastUsedApiConfig,
  }) : super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<UpdateConfigEvent>(_onUpdateConfig);
    on<UpdateRoleEvent>(_onUpdateRole);
    on<ClearMessagesEvent>(_onClearMessages);
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      // 加载消息历史
      final messages = await getMessages();
      
      // 优先加载上次使用的 API 配置，如果没有则使用默认配置
      APIConfig? configToUse;
      if (getLastUsedApiConfig != null) {
        configToUse = await getLastUsedApiConfig!();
      }
      if (configToUse == null && getDefaultApiConfig != null) {
        configToUse = await getDefaultApiConfig!();
      }
      
      // 总是加载默认角色，不考虑上次使用的角色
      AIRole? defaultRole;
      if (getDefaultRole != null) {
        defaultRole = await getDefaultRole!();
      }
      
      emit(MessagesLoaded(
        messages: messages,
        currentConfig: configToUse,
        currentRole: defaultRole,
      ));
    } catch (e) {
      emit(ChatError('加载消息失败: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (state is! MessagesLoaded) {
        emit(const ChatError('状态错误'));
        return;
      }

      final currentState = state as MessagesLoaded;
      
      // 设置发送中状态
      emit(currentState.copyWith(isSending: true));
      
      // 获取要使用的配置和角色
      final apiConfig = event.apiConfig ?? currentState.currentConfig;
      final role = event.role ?? currentState.currentRole;
      
      if (apiConfig == null) {
        emit(currentState.copyWith(isSending: false));
        emit(const ChatError('请先配置API设置'));
        return;
      }
      
      // 发送消息并获取响应
      await sendMessage(
        event.text,
        apiConfig: apiConfig,
        systemPrompt: role?.systemPrompt,
      );
      
      // 获取更新后的消息列表
      final updatedMessages = await getMessages();
      
      emit(currentState.copyWith(
        messages: updatedMessages,
        isSending: false,
      ));
    } catch (e) {
      if (state is MessagesLoaded) {
        emit((state as MessagesLoaded).copyWith(isSending: false));
      }
      emit(ChatError('发送消息失败: $e'));
    }
  }

  Future<void> _onUpdateConfig(UpdateConfigEvent event, Emitter<ChatState> emit) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      // 保存最后使用的 API 配置，确保重启后仍然使用
      if (saveLastUsedApiConfig != null) {
        await saveLastUsedApiConfig!(event.config);
      }
      
      // 发出新的状态，更新当前使用的API配置
      emit(currentState.copyWith(currentConfig: event.config));
      // 延迟一点时间后重新发出状态，确保UI有反应
      await Future.delayed(const Duration(milliseconds: 10));
      emit(currentState.copyWith(currentConfig: event.config));
    }
  }

  Future<void> _onUpdateRole(UpdateRoleEvent event, Emitter<ChatState> emit) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      
      // 不保存角色选择，仅在当前会话中更新
      emit(currentState.copyWith(currentRole: event.role));
      // 延迟一点时间后重新发出状态，确保UI有反应
      await Future.delayed(const Duration(milliseconds: 10));
      emit(currentState.copyWith(currentRole: event.role));
    }
  }

  Future<void> _onClearMessages(
    ClearMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (state is! MessagesLoaded) {
        emit(const ChatError('状态错误'));
        return;
      }

      final currentState = state as MessagesLoaded;
      await clearConversation();
      
      emit(currentState.copyWith(messages: []));
    } catch (e) {
      emit(ChatError('清空对话失败: $e'));
    }
  }
}
