import '../models/api_config.dart';
import 'storage_service.dart';

class APIConfigService {
  final StorageService _storage = StorageService();
  
  Future<List<APIConfig>> loadConfigs() async {
    final data = await _storage.loadData(StorageService.configKey);
    return data.map((json) => APIConfig.fromJson(json)).toList();
  }

  Future<void> saveConfig(APIConfig config) async {
    final configs = await loadConfigs();
    final index = configs.indexWhere((c) => c.id == config.id);
    
    if (index >= 0) {
      configs[index] = config;
    } else {
      configs.add(config);
    }

    await _storage.saveData(
      StorageService.configKey,
      configs.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> deleteConfig(String id) async {
    final configs = await loadConfigs();
    configs.removeWhere((c) => c.id == id);
    await _storage.saveData(
      StorageService.configKey,
      configs.map((c) => c.toJson()).toList(),
    );
  }

  Future<APIConfig?> getDefaultConfig() async {
    final configs = await loadConfigs();
    return configs.cast<APIConfig?>().firstWhere(
      (c) => c?.isDefault ?? false,
      orElse: () => null,
    );
  }

  Future<void> setDefaultConfig(String id) async {
    final configs = await loadConfigs();
    for (var i = 0; i < configs.length; i++) {
      configs[i] = configs[i].copyWith(
        isDefault: configs[i].id == id,
      );
    }
    await _storage.saveData(
      StorageService.configKey,
      configs.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> removeDefaultConfig() async {
    final configs = await loadConfigs();
    for (var i = 0; i < configs.length; i++) {
      if (configs[i].isDefault) {
        configs[i] = configs[i].copyWith(isDefault: false);
      }
    }
    await _storage.saveData(
      StorageService.configKey,
      configs.map((c) => c.toJson()).toList(),
    );
  }
}
