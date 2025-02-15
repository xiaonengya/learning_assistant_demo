import '../models/ai_preset_text.dart';
import 'storage_service.dart';

class AIPresetTextService {
  final StorageService _storage = StorageService();

  Future<List<AIPresetText>> loadPresets() async {
    final data = await _storage.loadData(StorageService.presetKey);
    return data.map((json) => AIPresetText.fromJson(json)).toList();
  }

  Future<void> savePreset(AIPresetText preset) async {
    final presets = await loadPresets();
    final index = presets.indexWhere((p) => p.id == preset.id);

    if (index >= 0) {
      presets[index] = preset;
    } else {
      presets.add(preset);
    }

    await _storage.saveData(
      StorageService.presetKey,
      presets.map((p) => p.toJson()).toList(),
    );
  }

  Future<void> deletePreset(String id) async {
    final presets = await loadPresets();
    presets.removeWhere((p) => p.id == id);
    await _storage.saveData(
      StorageService.presetKey,
      presets.map((p) => p.toJson()).toList(),
    );
  }

  Future<AIPresetText?> getDefaultPreset() async {
    final presets = await loadPresets();
    return presets.cast<AIPresetText?>().firstWhere(
          (p) => p?.isDefault ?? false,
          orElse: () => null,
        );
  }

  Future<void> setDefaultPreset(String id) async {
    final presets = await loadPresets();
    for (var i = 0; i < presets.length; i++) {
      presets[i] = presets[i].copyWith(
        isDefault: presets[i].id == id,
      );
    }
    await _storage.saveData(
      StorageService.presetKey,
      presets.map((p) => p.toJson()).toList(),
    );
  }

  Future<void> removeDefaultPreset() async {
    final presets = await loadPresets();
    for (var i = 0; i < presets.length; i++) {
      if (presets[i].isDefault) {
        presets[i] = presets[i].copyWith(isDefault: false);
      }
    }
    await _storage.saveData(
      StorageService.presetKey,
      presets.map((p) => p.toJson()).toList(),
    );
  }
}
