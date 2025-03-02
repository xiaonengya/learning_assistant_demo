import '../models/chat_message.dart';
import '../models/api_config.dart';

/// 聊天仓库接口
abstract class ChatRepository {
  /// 获取聊天消息历史
  Future<List<ChatMessage>> getMessages();

  /// 发送消息并获取响应
  Future<ChatMessage> sendMessage(
    String text, {
    APIConfig? apiConfig,
    String? systemPrompt,
  });

  /// 保存消息列表
  Future<void> saveMessages(List<ChatMessage> messages);

  /// 清空对话
  Future<void> clearConversation();
}
