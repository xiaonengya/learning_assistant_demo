import '../../domain/models/chat_message.dart';
import '../../domain/models/api_config.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/local_storage_source.dart';
import '../datasources/remote/ai_api_source.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/uuid_generator.dart';

class ChatRepositoryImpl implements ChatRepository {
  final LocalStorageSource _localStorage;
  final AIApiSource _apiSource;
  List<ChatMessage> _cachedMessages = [];

  ChatRepositoryImpl(this._localStorage, this._apiSource);

  @override
  Future<List<ChatMessage>> getMessages() async {
    // 如果缓存不为空，返回缓存
    if (_cachedMessages.isNotEmpty) {
      return _cachedMessages;
    }

    // 从本地存储加载消息
    final messagesJson = _localStorage.getData<List<dynamic>>(StorageKeys.CHAT_MESSAGES);
    
    if (messagesJson != null) {
      _cachedMessages = messagesJson
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // 确保消息按时间排序（最新的在前）
      _cachedMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return _cachedMessages;
    }
    
    return [];
  }

  @override
  Future<ChatMessage> sendMessage(
    String text, {
    APIConfig? apiConfig,
    String? systemPrompt,
  }) async {
    if (apiConfig == null) {
      throw ArgumentError('API配置不能为空');
    }
    
    // 创建并保存用户消息
    final userMessage = ChatMessage(
      id: UuidGenerator.generate(),
      text: text,
      isUser: true,
    );
    
    _cachedMessages.insert(0, userMessage);
    await saveMessages(_cachedMessages);
    
    try {
      // 获取历史消息作为上下文
      final previousMessages = _cachedMessages
          .where((msg) => msg != userMessage)  // 排除当前消息
          .take(10)  // 只取最近的10条
          .toList()
          .reversed  // 反转为时间正序
          .toList();
      
      // 调用API获取回复
      final responseText = await _apiSource.sendMessage(
        message: text,
        apiConfig: apiConfig,
        systemPrompt: systemPrompt,
        previousMessages: previousMessages,
      );
      
      // 创建并保存AI回复消息
      final aiMessage = ChatMessage(
        id: UuidGenerator.generate(),
        text: responseText,
        isUser: false,
      );
      
      _cachedMessages.insert(0, aiMessage);
      await saveMessages(_cachedMessages);
      
      return aiMessage;
    } catch (e) {
      // 创建错误消息
      final errorMessage = ChatMessage(
        id: UuidGenerator.generate(),
        text: '发送消息时出错: $e',
        isUser: false,
        isError: true,
      );
      
      _cachedMessages.insert(0, errorMessage);
      await saveMessages(_cachedMessages);
      
      throw Exception('API调用失败: $e');
    }
  }

  @override
  Future<void> saveMessages(List<ChatMessage> messages) async {
    _cachedMessages = messages;
    
    // 转换为JSON并保存到本地存储
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    await _localStorage.saveData(StorageKeys.CHAT_MESSAGES, jsonList);
  }

  @override
  Future<void> clearConversation() async {
    _cachedMessages = [];
    await _localStorage.removeData(StorageKeys.CHAT_MESSAGES);
  }
}
