import 'package:flutter/material.dart';
import '../../../domain/models/ai_preset_text.dart';

class PresetSelector extends StatelessWidget {
  final List<AIPresetText> presets;
  final AIPresetText? selectedPreset;
  final Function(AIPresetText) onPresetSelected;

  const PresetSelector({
    super.key,
    required this.presets,
    this.selectedPreset,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) {
      return TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('添加预设'),
        onPressed: () {
          // 导航到预设管理页面
          Navigator.pushNamed(context, '/presets');
        },
      );
    }
    
    return DropdownButton<String>(
      value: selectedPreset?.id,
      hint: const Text('预设文本'),
      underline: Container(
        height: 2,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      onChanged: (String? id) {
        if (id != null) {
          final preset = presets.firstWhere((p) => p.id == id);
          onPresetSelected(preset);
        }
      },
      items: presets.map<DropdownMenuItem<String>>((AIPresetText preset) {
        return DropdownMenuItem<String>(
          value: preset.id,
          child: SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preset.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (preset.isDefault)
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                  ],
                ),
                Text(
                  preset.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
