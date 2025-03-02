import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/api_config.dart';
import '../../domain/repositories/api_config_repository.dart';
import '../datasources/local/local_storage_source.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/uuid_generator.dart';

/// API配置仓库实现
class ApiConfigRepositoryImpl implements ApiConfigRepository {
  static const String apiConfigsKey = 'api_configs';
  static const String defaultConfigKey = 'default_api_config';
  static const String lastUsedConfigKey = 'last_used_api_config';

  final LocalStorageSource _localStorage;
  
  ApiConfigRepositoryImpl(this._localStorage);
  
  @override
  Future<List<APIConfig>> getConfigs() async {
    final data = _localStorage.getData<List<dynamic>>(StorageKeys.API_CONFIGS);
    if (data == null) return [];
    
    return data.map((json) => APIConfig.fromJson(json)).toList();
  }
  
  @override
  Future<APIConfig?> getDefaultConfig() async {
    final configs = await getConfigs();
    return configs.cast<APIConfig?>().firstWhere(
      (c) => c?.isDefault ?? false,
      orElse: () => null,
    );
  }
  
  @override
  Future<void> saveConfig(APIConfig config) async {
    final configs = await getConfigs();
    final index = configs.indexWhere((c) => c.id == config.id);
    
    if (index >= 0) {
      configs[index] = config;
    } else {
      // 如果是新配置，使用UUID生成ID
      final newConfig = index < 0 && config.id.isEmpty 
          ? APIConfig(
              id: UuidGenerator.generate(),
              name: config.name,
              apiKey: config.apiKey,
              apiEndpoint: config.apiEndpoint,
              model: config.model,
              isDefault: config.isDefault,
              temperature: config.temperature,
            )
          : config;
      
      configs.add(newConfig);
    }
    
    await _localStorage.saveData(
      StorageKeys.API_CONFIGS,
      configs.map((c) => c.toJson()).toList(),
    );
  }
  
  @override
  Future<void> deleteConfig(String id) async {
    final configs = await getConfigs();
    configs.removeWhere((c) => c.id == id);
    
    await _localStorage.saveData(
      StorageKeys.API_CONFIGS,
      configs.map((c) => c.toJson()).toList(),
    );
  }
  
  @override
  Future<void> setDefaultConfig(String id) async {
    final configs = await getConfigs();
    
    for (var i = 0; i < configs.length; i++) {
      configs[i] = configs[i].copyWith(
        isDefault: configs[i].id == id,
      );
    }
    
    await _localStorage.saveData(
      StorageKeys.API_CONFIGS,
      configs.map((c) => c.toJson()).toList(),
    );
  }
  
  @override
  Future<void> removeDefaultConfig() async {
    final configs = await getConfigs();
    
    for (var i = 0; i < configs.length; i++) {
      if (configs[i].isDefault) {
        configs[i] = configs[i].copyWith(isDefault: false);
      }
    }
    
    await _localStorage.saveData(
      StorageKeys.API_CONFIGS,
      configs.map((c) => c.toJson()).toList(),
    );
  }

  @override
  Future<APIConfig?> getLastUsedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUsedId = prefs.getString(lastUsedConfigKey);
    if (lastUsedId == null) return null;
    
    final configs = await getConfigs();
    return configs.firstWhere(
      (config) => config.id == lastUsedId,
      orElse: () => throw Exception('找不到上次使用的API配置'),
    );
  }
  
  @override
  Future<void> saveLastUsedConfig(APIConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastUsedConfigKey, config.id);
  }
}
