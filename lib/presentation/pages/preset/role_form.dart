import 'package:flutter/material.dart';
import '../../../domain/models/ai_role.dart';

class RoleForm extends StatefulWidget {
  final AIRole? initialRole;
  final Function(AIRole) onSave;

  const RoleForm({
    Key? key,
    this.initialRole,
    required this.onSave,
  }) : super(key: key);

  @override
  State<RoleForm> createState() => _RoleFormState();
}

class _RoleFormState extends State<RoleForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _systemPromptController;
  String _selectedCategory = '助手';
  bool _isDefault = false;
  
  // 预定义的角色类别
  final List<String> _categories = [
    '助手',
    '技术',
    '教育',
    '创作',
    '翻译',
    '分析',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.initialRole?.name ?? '');
    _descriptionController = TextEditingController(text: widget.initialRole?.description ?? '');
    _systemPromptController = TextEditingController(text: widget.initialRole?.systemPrompt ?? '');
    _selectedCategory = widget.initialRole?.category ?? '助手';
    _isDefault = widget.initialRole?.isDefault ?? false;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 定义统一的样式和间距
    const double verticalSpacing = 24.0;  // 增加间距为24px，使布局更宽松
    const double formPadding = 20.0;     // 增加表单内边距
    
    // 输入框装饰样式
    final inputDecoration = (String label, String hint) => InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // 统一内部边距
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(formPadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 450,     // 增加最小宽度，确保在各种设备上表单足够宽
              maxWidth: 700,     // 增加最大宽度
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  Text(
                    widget.initialRole == null ? '添加AI角色' : '编辑AI角色',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: verticalSpacing),
                  
                  // 角色名称
                  TextFormField(
                    controller: _nameController,
                    decoration: inputDecoration('角色名称', '例如: 编程助手'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入角色名称';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: verticalSpacing),
                  
                  // 角色描述
                  TextFormField(
                    controller: _descriptionController,
                    decoration: inputDecoration('角色描述', '简短描述这个AI角色的特点和用途'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入角色描述';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: verticalSpacing),
                  
                  // 角色类别下拉菜单
                  DropdownButtonFormField<String>(
                    decoration: inputDecoration('角色类别', '选择一个类别'),
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: verticalSpacing),
                  
                  // 系统提示文本（大型文本区域）
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '系统提示词(System Prompt)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '这是发送给AI的指令，用于定义其行为和能力',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _systemPromptController,
                          decoration: InputDecoration(
                            hintText: '输入系统提示词，例如："你是一个专业的编程助手..."',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16.0),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          maxLines: 8, // 设置为多行输入
                          minLines: 6, // 增加最小行数
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入系统提示词';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: verticalSpacing),
                  
                  // 设为默认选项
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    title: const Text('设为默认角色'),
                    subtitle: const Text('新建对话时将自动使用此角色'),
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value;
                      });
                    },
                    secondary: Icon(
                      Icons.star,
                      color: _isDefault
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                  
                  const SizedBox(height: verticalSpacing),
                  
                  // 角色示例提示
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '角色提示词示例',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '编程助手:\n"你是一个专业的编程助手，擅长解答各种编程问题和代码调试。请提供清晰简洁的解释，并在可能的情况下提供代码示例。"\n\n'
                          '学习导师:\n"你是一个耐心的学习导师，专长于将复杂概念解释得简单易懂。请用生动的例子和类比来帮助理解，并鼓励提问。"',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: verticalSpacing),
                  
                  // 按钮区域
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveRole,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 48), // 增加按钮尺寸
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveRole() {
    if (_formKey.currentState!.validate()) {
      final role = AIRole(
        id: widget.initialRole?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        systemPrompt: _systemPromptController.text,
        category: _selectedCategory,
        isDefault: _isDefault,
      );
      
      widget.onSave(role);
      Navigator.of(context).pop();
    }
  }
}
