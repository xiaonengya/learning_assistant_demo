import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/models/api_config.dart';
import '../../../domain/models/chat_message.dart';

/// AI API数据源
class AIApiSource {
  final http.Client _httpClient;
  
  AIApiSource(this._httpClient);
  
  /// 发送消息到AI API
  Future<String> sendMessage({
    required String message,
    required APIConfig apiConfig,
    String? systemPrompt,
    List<ChatMessage>? previousMessages,
  }) async {
    try {
      // 根据当前的API配置选择不同的处理方式
      if (apiConfig.apiEndpoint.contains('openai')) {
        return await _sendToOpenAI(
          message: message,
          apiConfig: apiConfig,
          systemPrompt: systemPrompt,
          previousMessages: previousMessages,
        );
      } else if (apiConfig.apiEndpoint.contains('moonshot')) {
        return await _sendToMoonshot(
          message: message,
          apiConfig: apiConfig,
          systemPrompt: systemPrompt,
          previousMessages: previousMessages,
        );
      } else if (apiConfig.apiEndpoint.contains('anthropic')) {
        return await _sendToAnthropic(
          message: message,
          apiConfig: apiConfig,
          systemPrompt: systemPrompt,
          previousMessages: previousMessages,
        );
      } else {
        // 默认使用通用格式
        return await _sendToOpenAI(
          message: message,
          apiConfig: apiConfig,
          systemPrompt: systemPrompt,
          previousMessages: previousMessages,
        );
      }
    } catch (e) {
      // 记录异常并重新抛出
      print('AI API调用失败: $e');
      rethrow;
    }
  }
  
  /// 发送消息到OpenAI API
  Future<String> _sendToOpenAI({
    required String message,
    required APIConfig apiConfig,
    String? systemPrompt,
    List<ChatMessage>? previousMessages,
  }) async {
    final url = '${apiConfig.apiEndpoint}/chat/completions';
    
    // 构建消息历史
    List<Map<String, String>> messages = [];
    
    // 如果有系统提示，添加系统消息
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messages.add({
        'role': 'system',
        'content': systemPrompt,
      });
    }
    
    // 添加历史消息
    if (previousMessages != null) {
      for (final msg in previousMessages) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }
    }
    
    // 添加当前用户消息
    messages.add({
      'role': 'user',
      'content': message,
    });
    
    // 构建请求体
    final body = jsonEncode({
      'model': apiConfig.model,
      'messages': messages,
      'temperature': apiConfig.temperature,
    });
    
    // 发送请求
    final response = await _httpClient.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${apiConfig.apiKey}',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    
    // 检查响应
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI API调用失败: ${response.statusCode}\n${response.body}');
    }
  }
  
  /// 发送消息到Moonshot API (Kimi)
  Future<String> _sendToMoonshot({
    required String message,
    required APIConfig apiConfig,
    String? systemPrompt,
    List<ChatMessage>? previousMessages,
  }) async {
    // Moonshot API与OpenAI API兼容
    return _sendToOpenAI(
      message: message,
      apiConfig: apiConfig,
      systemPrompt: systemPrompt,
      previousMessages: previousMessages,
    );
  }
  
  /// 发送消息到Anthropic API (Claude)
  Future<String> _sendToAnthropic({
    required String message,
    required APIConfig apiConfig,
    String? systemPrompt,
    List<ChatMessage>? previousMessages,
  }) async {
    final url = '${apiConfig.apiEndpoint}/messages';
    
    // 构建系统提示
    String system = systemPrompt ?? '';
    
    // 构建消息历史
    List<Map<String, dynamic>> messages = [];
    
    // 添加历史消息
    if (previousMessages != null) {
      for (final msg in previousMessages) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }
    }
    
    // 添加当前用户消息
    messages.add({
      'role': 'user',
      'content': message,
    });
    
    // 构建请求体
    final body = jsonEncode({
      'model': apiConfig.model,
      'messages': messages,
      'system': system,
      'temperature': apiConfig.temperature,
    });
    
    // 发送请求
    final response = await _httpClient.post(
      Uri.parse(url),
      headers: {
        'x-api-key': apiConfig.apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    
    // 检查响应
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['content'][0]['text'];
    } else {
      throw Exception('Anthropic API调用失败: ${response.statusCode}\n${response.body}');
    }
  }
}
