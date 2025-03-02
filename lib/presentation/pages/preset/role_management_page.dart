import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/preset/preset_bloc.dart';
import '../../../domain/models/ai_role.dart';
import '../../widgets/common/loading_indicator.dart';

class RoleManagementPage extends StatelessWidget {
  const RoleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI角色管理'),
      ),
      body: BlocConsumer<PresetBloc, PresetState>(
        listener: (context, state) {
          if (state is PresetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PresetLoading) {
            return const LoadingIndicator(message: '加载角色中...');
          } else if (state is PresetsLoaded) {
            return _buildRoleList(context, state);
          } else {
            return const Center(
              child: Text('加载失败，请重试'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditRoleDialog(context),
        tooltip: '添加角色',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoleList(BuildContext context, PresetsLoaded state) {
    if (state.roles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            const Text('暂无角色'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddEditRoleDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('添加角色'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.roles.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final role = state.roles[index];
        final isDefault = role.id == state.defaultRole?.id;

        return Card(
          elevation: isDefault ? 4 : 1,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isDefault
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: ExpansionTile(
            leading: Icon(
              _getCategoryIcon(role.category),
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Row(
              children: [
                Text(
                  role.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isDefault)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: const Text('默认'),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              role.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.star,
                    color: isDefault
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  tooltip: isDefault ? '默认角色' : '设为默认',
                  onPressed: isDefault
                      ? null
                      : () {
                          context
                              .read<PresetBloc>()
                              .add(SetDefaultRoleEvent(role.id));
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: '编辑',
                  onPressed: () => _showAddEditRoleDialog(context, role),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: '删除',
                  onPressed: () => _confirmDelete(context, role),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '系统提示词:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(role.systemPrompt),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '类别: ${role.category}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '技术':
        return Icons.code;
      case '教育':
        return Icons.school;
      case '创作':
        return Icons.edit;
      case '翻译':
        return Icons.translate;
      case '分析':
        return Icons.analytics;
      default:
        return Icons.psychology;
    }
  }

  void _confirmDelete(BuildContext context, AIRole role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除角色'),
        content: Text('确定要删除角色 "${role.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PresetBloc>().add(DeleteRoleEvent(role.id));
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddEditRoleDialog(BuildContext context, [AIRole? role]) {
    showDialog(
      context: context,
      builder: (context) => RoleDialog(
        role: role,
        onSave: (newRole) {
          context.read<PresetBloc>().add(SaveRoleEvent(newRole));
        },
      ),
    );
  }
}

class RoleDialog extends StatefulWidget {
  final AIRole? role;
  final Function(AIRole) onSave;

  const RoleDialog({
    super.key,
    this.role,
    required this.onSave,
  });

  @override
  State<RoleDialog> createState() => _RoleDialogState();
}

class _RoleDialogState extends State<RoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _systemPromptController = TextEditingController();
  String _selectedCategory = roleCategories.first;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _nameController.text = widget.role!.name;
      _descriptionController.text = widget.role!.description;
      _systemPromptController.text = widget.role!.systemPrompt;
      _selectedCategory = widget.role!.category;
      _isDefault = widget.role!.isDefault;
    }
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
    return AlertDialog(
      title: Text(widget.role == null ? '添加角色' : '编辑角色'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '角色名称',
                  hintText: '例如: 技术导师',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入角色名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '角色描述',
                  hintText: '简短描述这个角色',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入角色描述';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 系统提示词
              TextFormField(
                controller: _systemPromptController,
                decoration: const InputDecoration(
                  labelText: '系统提示词',
                  hintText: '角色的系统提示词',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入系统提示词';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 类别选择
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '类别',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: roleCategories.map<DropdownMenuItem<String>>((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue ?? roleCategories.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 设为默认
              CheckboxListTile(
                title: const Text('设为默认角色'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveRole,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _saveRole() {
    if (_formKey.currentState?.validate() ?? false) {
      final role = AIRole(
        id: widget.role?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        systemPrompt: _systemPromptController.text,
        category: _selectedCategory,
        isDefault: _isDefault,
        createdAt: widget.role?.createdAt,
      );
      widget.onSave(role);
      Navigator.pop(context);
    }
  }
}
