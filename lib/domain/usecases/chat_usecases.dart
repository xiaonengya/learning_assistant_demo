import '../models/chat_message.dart';
import '../models/api_config.dart';
import '../repositories/chat_repository.dart';

/// 获取聊天消息历史的用例
class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  /// 执行用例，获取消息列表
  Future<List<ChatMessage>> call() {
    return repository.getMessages();
  }
}

/// 发送消息的用例
class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  /// 执行用例，发送消息并获取响应
  Future<ChatMessage> call(
    String text, {
    APIConfig? apiConfig,
    String? systemPrompt,
  }) {
    return repository.sendMessage(
      text,
      apiConfig: apiConfig,
      systemPrompt: systemPrompt,
    );
  }
}

/// 保存消息的用例
class SaveMessages {
  final ChatRepository repository;

  SaveMessages(this.repository);

  /// 执行用例，保存消息列表
  Future<void> call(List<ChatMessage> messages) {
    return repository.saveMessages(messages);
  }
}

/// 清空对话的用例
class ClearConversation {
  final ChatRepository repository;

  ClearConversation(this.repository);

  /// 执行用例，清空对话
  Future<void> call() {
    return repository.clearConversation();
  }
}
