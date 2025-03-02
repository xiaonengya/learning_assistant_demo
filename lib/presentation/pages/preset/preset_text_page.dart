import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/preset/preset_bloc.dart';
import '../../../domain/models/ai_preset_text.dart';
import '../../widgets/common/loading_indicator.dart';

class PresetTextPage extends StatelessWidget {
  const PresetTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预设文本管理'),
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
            return const LoadingIndicator(message: '加载预设文本中...');
          } else if (state is PresetsLoaded) {
            return _buildPresetList(context, state);
          } else {
            return const Center(
              child: Text('加载失败，请重试'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        tooltip: '添加预设文本',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPresetList(BuildContext context, PresetsLoaded state) {
    if (state.presetTexts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.text_snippet,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            const Text('暂无预设文本'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('添加预设文本'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.presetTexts.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final preset = state.presetTexts[index];
        final isDefault = preset.id == state.defaultPresetText?.id;

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
            leading: const Icon(Icons.text_snippet),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    preset.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
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
              preset.content,
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
                  tooltip: isDefault ? '默认预设' : '设为默认',
                  onPressed: isDefault
                      ? null
                      : () {
                          context
                              .read<PresetBloc>()
                              .add(SetDefaultPresetTextEvent(preset.id));
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy),
                  tooltip: '复制文本',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: preset.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已复制到剪贴板')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: '编辑',
                  onPressed: () => _showAddEditDialog(context, preset),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: '删除',
                  onPressed: () => _confirmDelete(context, preset),
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
                      '预设内容:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(preset.content),
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

  void _confirmDelete(BuildContext context, AIPresetText preset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除预设文本'),
        content: Text('确定要删除预设文本 "${preset.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PresetBloc>().add(DeletePresetTextEvent(preset.id));
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, [AIPresetText? preset]) {
    showDialog(
      context: context,
      builder: (context) => PresetTextDialog(
        preset: preset,
        onSave: (newPreset) {
          context.read<PresetBloc>().add(SavePresetTextEvent(newPreset));
        },
      ),
    );
  }
}

class PresetTextDialog extends StatefulWidget {
  final AIPresetText? preset;
  final Function(AIPresetText) onSave;

  const PresetTextDialog({
    super.key,
    this.preset,
    required this.onSave,
  });

  @override
  State<PresetTextDialog> createState() => _PresetTextDialogState();
}

class _PresetTextDialogState extends State<PresetTextDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.preset != null) {
      _nameController.text = widget.preset!.name;
      _contentController.text = widget.preset!.content;
      _isDefault = widget.preset!.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.preset == null ? '添加预设文本' : '编辑预设文本'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  hintText: '输入预设名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '文本内容',
                  hintText: '输入预设文本',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入文本内容';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('设为默认预设'),
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
          onPressed: _savePreset,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _savePreset() {
    if (_formKey.currentState?.validate() ?? false) {
      final preset = AIPresetText(
        id: widget.preset?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        content: _contentController.text,
        isDefault: _isDefault,
      );
      widget.onSave(preset);
      Navigator.pop(context);
    }
  }
}
