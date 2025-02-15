class AIRole {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final String category;
  final bool isDefault;
  final DateTime createdAt;

  AIRole({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.category,
    this.isDefault = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'systemPrompt': systemPrompt,
    'category': category,
    'isDefault': isDefault,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AIRole.fromJson(Map<String, dynamic> json) => AIRole(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    systemPrompt: json['systemPrompt'],
    category: json['category'],
    isDefault: json['isDefault'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );
}

// 预定义的角色预设
final List<AIRole> defaultRoles = [
  AIRole(
    id: 'programmer',
    name: '代码专家',
    description: '专注于编程和技术问题的解答',
    category: '技术',
    systemPrompt: '你是一位资深的编程专家，精通多种编程语言和技术栈。请用专业、清晰的方式回答技术问题，并提供具体的代码示例。',
    isDefault: true,
  ),
  AIRole(
    id: 'teacher',
    name: '教学助手',
    description: '耐心的教育者',
    category: '教育',
    systemPrompt: '你是一位耐心的教师，善于将复杂的概念分解成易于理解的部分。回答时要考虑学习者的水平，循序渐进地解释。',
  ),
  AIRole(
    id: 'writer',
    name: '写作助手',
    description: '协助写作和内容创作',
    category: '创作',
    systemPrompt: '你是一位经验丰富的写作顾问，擅长帮助改进文章结构、措辞和表达。请提供具体的修改建议和创意灵感。',
  ),
];

// 角色类别
const List<String> roleCategories = ['技术', '教育', '创作', '翻译', '分析', '其他'];
