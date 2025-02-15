import '../models/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String _historyKey = 'chat_history';
  final SharedPreferences? _prefs;

  ChatService._internal(this._prefs);

  static Future<ChatService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ChatService._internal(prefs);
  }

  factory ChatService() => _instance;
  static final ChatService _instance = ChatService._internal(null);

  // 清理聊天历史
  Future<void> clearHistory() async {
    await _prefs?.remove(_historyKey);
  }

  // 发送消息
  Future<String> sendMessage({
    required String message,
    required APIConfig config,
  }) async {
    final url = Uri.parse('${config.apiEndpoint}/chat/completions');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.apiKey}',
        },
        body: jsonEncode({
          'model': config.model,
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'temperature': config.temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API请求失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('发送消息失败: $e');
    }
  }
}
