class APIConfig {
  final String id;
  final String name;
  final String apiKey;
  final String apiEndpoint;
  final String model;
  final bool isDefault;
  final double temperature;

  APIConfig({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.apiEndpoint,
    required this.model,
    this.isDefault = false,
    this.temperature = 0.7,
  });

  factory APIConfig.fromJson(Map<String, dynamic> json) {
    return APIConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      apiKey: json['apiKey'] as String,
      apiEndpoint: json['apiEndpoint'] as String,
      model: json['model'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      temperature: json['temperature'] as double? ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'apiKey': apiKey,
        'apiEndpoint': apiEndpoint,
        'model': model,
        'isDefault': isDefault,
        'temperature': temperature,
      };

  APIConfig copyWith({
    String? id,
    String? name,
    String? apiKey,
    String? apiEndpoint,
    String? model,
    bool? isDefault,
    double? temperature,
  }) {
    return APIConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      apiKey: apiKey ?? this.apiKey,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      model: model ?? this.model,
      isDefault: isDefault ?? this.isDefault,
      temperature: temperature ?? this.temperature,
    );
  }
}
