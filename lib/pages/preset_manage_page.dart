import 'package:flutter/material.dart';
import '../models/ai_preset_text.dart';
import '../services/ai_preset_text_service.dart';

class PresetManagePage extends StatefulWidget {
  const PresetManagePage({super.key});

  @override
  State<PresetManagePage> createState() => _PresetManagePageState();
}

class _PresetManagePageState extends State<PresetManagePage> {
  final AIPresetTextService _presetService = AIPresetTextService();
  List<AIPresetText> _presets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    setState(() => _isLoading = true);
    final presets = await _presetService.loadPresets();
    if (mounted) {
      setState(() {
        _presets = presets;
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewPreset() async {
    final result = await showDialog<AIPresetText>(
      context: context,
      builder: (context) => _PresetEditDialog(),
    );

    if (result != null) {
      await _presetService.savePreset(result);
      await _loadPresets();
    }
  }

  Future<void> _editPreset(AIPresetText preset) async {
    final result = await showDialog<AIPresetText>(
      context: context,
      builder: (context) => _PresetEditDialog(preset: preset),
    );

    if (result != null) {
      await _presetService.savePreset(result);
      await _loadPresets();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('预设管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewPreset,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _presets.length,
        itemBuilder: (context, index) {
          final preset = _presets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                preset.isDefault ? Icons.star : Icons.text_snippet,
                color: preset.isDefault ? Colors.amber : null,
              ),
              title: Text(preset.name),
              subtitle: Text(
                preset.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editPreset(preset),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('确认删除'),
                          content: const Text('确定要删除这个预设吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _presetService.deletePreset(preset.id);
                        await _loadPresets();
                      }
                    },
                  ),
                ],
              ),
              onTap: () => _editPreset(preset),
            ),
          );
        },
      ),
    );
  }
}

class _PresetEditDialog extends StatefulWidget {
  final AIPresetText? preset;

  const _PresetEditDialog({this.preset});

  @override
  State<_PresetEditDialog> createState() => _PresetEditDialogState();
}

class _PresetEditDialogState extends State<_PresetEditDialog> {
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.preset == null ? '新建预设' : '编辑预设'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '预设名称',
                hintText: '输入预设名称',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '预设内容',
                hintText: '输入预设文本内容',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('设为默认预设'),
              value: _isDefault,
              onChanged: (value) {
                setState(() => _isDefault = value ?? false);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _contentController.text.isEmpty) {
              return;
            }

            final preset = AIPresetText(
              id: widget.preset?.id ?? DateTime.now().toString(),
              name: _nameController.text,
              content: _contentController.text,
              isDefault: _isDefault,
            );

            Navigator.pop(context, preset);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
