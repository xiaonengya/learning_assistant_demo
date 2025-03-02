import '../models/api_config.dart';
import '../repositories/api_config_repository.dart';

/// 获取所有API配置
class GetApiConfigs {
  final ApiConfigRepository _repository;

  GetApiConfigs(this._repository);

  Future<List<APIConfig>> call() async {
    return await _repository.getConfigs();
  }
}

/// 获取默认API配置
class GetDefaultApiConfig {
  final ApiConfigRepository _repository;

  GetDefaultApiConfig(this._repository);

  Future<APIConfig?> call() async {
    return await _repository.getDefaultConfig();
  }
}

/// 保存API配置
class SaveApiConfig {
  final ApiConfigRepository _repository;

  SaveApiConfig(this._repository);

  Future<void> call(APIConfig config) async {
    await _repository.saveConfig(config);
  }
}

/// 删除API配置
class DeleteApiConfig {
  final ApiConfigRepository _repository;

  DeleteApiConfig(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteConfig(id);
  }
}

/// 设置默认API配置
class SetDefaultApiConfig {
  final ApiConfigRepository _repository;

  SetDefaultApiConfig(this._repository);

  Future<void> call(String id) async {
    await _repository.setDefaultConfig(id);
  }
}

/// 移除默认API配置
class RemoveDefaultApiConfig {
  final ApiConfigRepository _repository;

  RemoveDefaultApiConfig(this._repository);

  Future<void> call() async {
    await _repository.removeDefaultConfig();
  }
}

/// 获取最近使用的API配置
class GetLastUsedApiConfig {
  final ApiConfigRepository _repository;

  GetLastUsedApiConfig(this._repository);

  Future<APIConfig?> call() async {
    return await _repository.getLastUsedConfig();
  }
}

/// 保存最近使用的API配置
class SaveLastUsedApiConfig {
  final ApiConfigRepository _repository;

  SaveLastUsedApiConfig(this._repository);

  Future<void> call(APIConfig config) async {
    await _repository.saveLastUsedConfig(config);
  }
}
