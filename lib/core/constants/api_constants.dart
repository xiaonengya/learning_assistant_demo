/// API相关常量
class ApiConstants {
  // API端点
  static const String KIMI_ENDPOINT = 'https://api.moonshot.cn/v1';
  static const String OPENAI_ENDPOINT = 'https://api.openai.com/v1';
  static const String CLAUDE_ENDPOINT = 'https://api.anthropic.com/v1';
  static const int HTTP_NOT_FOUND = 404;
  static const int HTTP_SERVER_ERROR = 500;
  
  // HTTP请求头
  static const String CONTENT_TYPE = 'Content-Type';
  static const String AUTHORIZATION = 'Authorization';
  static const String APPLICATION_JSON = 'application/json';
  static const String ANTHROPIC_API_KEY = 'x-api-key';
  
  // 预定义的API端点
  static const String OPENAI_API_ENDPOINT = 'https://api.openai.com/v1';
  static const String MOONSHOT_API_ENDPOINT = 'https://api.moonshot.cn/v1';
  static const String ANTHROPIC_API_ENDPOINT = 'https://api.anthropic.com/v1';
  
  // 预定义的模型名称
  static const String GPT_3_5_TURBO = 'gpt-3.5-turbo';
  static const String GPT_4 = 'gpt-4';
  static const String GPT_4_TURBO = 'gpt-4-turbo';
  static const String CLAUDE_OPUS = 'claude-3-opus-20240229';
  static const String CLAUDE_SONNET = 'claude-3-sonnet-20240229';
  static const String CLAUDE_HAIKU = 'claude-3-haiku-20240307';
  static const String MOONSHOT_V1_8K = 'moonshot-v1-8k';
  static const String MOONSHOT_V1_32K = 'moonshot-v1-32k';
  
  // 不允许实例化
  ApiConstants._();
}
