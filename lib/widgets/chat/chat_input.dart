import 'package:flutter/material.dart';
import '../../models/ai_preset_text.dart';
import '../../services/ai_preset_text_service.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final AIPresetTextService _presetService = AIPresetTextService();
  List<AIPresetText> _presets = [];
  bool _showPresets = false;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await _presetService.loadPresets();
    if (mounted) {
      setState(() => _presets = presets);
    }
  }

  void _saveCurrentText() {
    if (widget.controller.text.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        bool isDefault = false;

        return AlertDialog(
          title: const Text('保存预设文本'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: '预设名称',
                  hintText: '输入预设名称',
                ),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('设为默认'),
                value: isDefault,
                onChanged: (value) =>
                    setState(() => isDefault = value ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (name.isNotEmpty) {
                  final preset = AIPresetText(
                    id: DateTime.now().toString(),
                    name: name,
                    content: widget.controller.text,
                    isDefault: isDefault,
                  );
                  await _presetService.savePreset(preset);
                  if (isDefault) {
                    await _presetService.setDefaultPreset(preset.id);
                  }
                  await _loadPresets();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showPresets && _presets.isNotEmpty)
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                final preset = _presets[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      widget.controller.text = preset.content;
                      setState(() => _showPresets = false);
                    },
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  preset.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (preset.isDefault)
                                const Icon(Icons.star,
                                    size: 16, color: Colors.amber),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              preset.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _showPresets ? Icons.close : Icons.format_list_bulleted,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  setState(() => _showPresets = !_showPresets);
                },
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  enabled: !widget.isLoading,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveCurrentText,
              ),
              IconButton(
                icon: Icon(
                  widget.isLoading ? Icons.hourglass_empty : Icons.send,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: widget.isLoading
                    ? null
                    : () => widget.onSubmit(widget.controller.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
