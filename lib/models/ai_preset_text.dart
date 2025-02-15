class AIPresetText {
  final String id;
  final String name;
  final String content;
  final bool isDefault;

  AIPresetText({
    required this.id,
    required this.name,
    required this.content,
    this.isDefault = false,
  });

  factory AIPresetText.fromJson(Map<String, dynamic> json) {
    return AIPresetText(
      id: json['id'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'content': content,
        'isDefault': isDefault,
      };

  AIPresetText copyWith({
    String? id,
    String? name,
    String? content,
    bool? isDefault,
  }) {
    return AIPresetText(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
