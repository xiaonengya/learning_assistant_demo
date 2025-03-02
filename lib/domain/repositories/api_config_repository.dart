import '../models/api_config.dart';

/// API配置仓库接口
abstract class ApiConfigRepository {
  /// 获取所有配置
  Future<List<APIConfig>> getConfigs();

  /// 获取默认配置
  Future<APIConfig?> getDefaultConfig();

  /// 保存配置
  Future<void> saveConfig(APIConfig config);

  /// 删除配置
  Future<void> deleteConfig(String id);

  /// 设置默认配置
  Future<void> setDefaultConfig(String id);

  /// 清除默认配置
  Future<void> removeDefaultConfig();
  
  /// 获取上次使用的配置
  Future<APIConfig?> getLastUsedConfig();
  
  /// 保存上次使用的配置
  Future<void> saveLastUsedConfig(APIConfig config);
}
