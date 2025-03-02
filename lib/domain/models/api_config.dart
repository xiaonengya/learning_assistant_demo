/// API配置模型
class APIConfig {
  final String id;
  final String name;
  final String apiKey;
  final String apiEndpoint;
  final String model;
  final double temperature;
  final bool isDefault;

  APIConfig({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.apiEndpoint,
    required this.model,
    this.temperature = 0.7,
    this.isDefault = false,
  });

  factory APIConfig.fromJson(Map<String, dynamic> json) {
    return APIConfig(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      apiKey: json['apiKey'] ?? '',
      apiEndpoint: json['apiEndpoint'] ?? '',
      model: json['model'] ?? '',
      temperature: json['temperature']?.toDouble() ?? 0.7,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'apiKey': apiKey,
      'apiEndpoint': apiEndpoint,
      'model': model,
      'temperature': temperature,
      'isDefault': isDefault,
    };
  }

  APIConfig copyWith({
    String? id,
    String? name,
    String? apiKey,
    String? apiEndpoint,
    String? model,
    double? temperature,
    bool? isDefault,
  }) {
    return APIConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      apiKey: apiKey ?? this.apiKey,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
