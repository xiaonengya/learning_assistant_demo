import 'package:equatable/equatable.dart';

/// 对话预设模型
class Preset extends Equatable {
  /// 预设ID
  final String id;
  
  /// 预设名称
  final String name;
  
  /// 预设描述
  final String description;
  
  /// 系统提示词
  final String systemPrompt;
  
  /// 示例对话
  final String examples;
  
  /// AI回复温度 (0.0-2.0)
  final double temperature;
  
  const Preset({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    this.examples = '',
    this.temperature = 0.7,
  });
  
  /// 从JSON创建Preset对象
  factory Preset.fromJson(Map<String, dynamic> json) {
    return Preset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      systemPrompt: json['systemPrompt'] as String,
      examples: json['examples'] as String? ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
    );
  }
  
  /// 转换为JSON对象
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'systemPrompt': systemPrompt,
      'examples': examples,
      'temperature': temperature,
    };
  }
  
  /// 创建一个具有新值的Preset副本
  Preset copyWith({
    String? id,
    String? name,
    String? description,
    String? systemPrompt,
    String? examples,
    double? temperature,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      examples: examples ?? this.examples,
      temperature: temperature ?? this.temperature,
    );
  }
  
  @override
  List<Object?> get props => [id, name, description, systemPrompt, examples, temperature];
}
