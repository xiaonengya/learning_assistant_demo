class APIConfig {
  static const String KIMI_ENDPOINT = 'https://api.moonshot.cn/v1';
  static const String OPENAI_ENDPOINT = 'https://api.openai.com/v1';
  
  static const Map<String, String> DEFAULT_MODELS = {
    'kimi': 'moonshot-v1-8k',
    'openai': 'gpt-3.5-turbo',
  };
}
