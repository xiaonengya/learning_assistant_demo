import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/api_config.dart';

class AIChatService {
  static const String _messagesKey = 'chat_messages';
  static final AIChatService _instance = AIChatService._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory AIChatService() => _instance;
  AIChatService._internal();

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  Future<List<ChatMessage>> loadMessages() async {
    await init();
    final messagesJson = _prefs.getStringList(_messagesKey) ?? [];
    return messagesJson
        .map((e) => ChatMessage.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveMessage(ChatMessage message) async {
    await init();
    final messages = await loadMessages();
    messages.insert(0, message);
    await _saveMessages(messages);
  }

  Future<void> _saveMessages(List<ChatMessage> messages) async {
    final messagesJson = messages.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_messagesKey, messagesJson);
  }

  Future<void> clearMessages() async {
    await init();
    await _prefs.setStringList(_messagesKey, []);
  }

  Future<String> sendMessage({
    required String message,
    required APIConfig config,
    required String systemPrompt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${config.apiEndpoint}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.apiKey}',
        },
        body: jsonEncode({
          'model': config.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': message}
          ],
          'temperature': config.temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API请求失败: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      throw Exception('发送消息失败: $e');
    }
  }

}
