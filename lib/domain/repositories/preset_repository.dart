import '../models/ai_preset_text.dart';
import '../models/ai_role.dart';

/// 预设仓库接口
abstract class PresetRepository {
  // AI角色相关方法
  
  /// 获取所有角色
  Future<List<AIRole>> getRoles();
  
  /// 获取默认角色
  Future<AIRole?> getDefaultRole();
  
  /// 保存角色
  Future<void> saveRole(AIRole role);
  
  /// 删除角色
  Future<void> deleteRole(String id);
  
  /// 设置默认角色
  Future<void> setDefaultRole(String id);

  // 预设文本相关方法
  
  /// 获取所有预设文本
  Future<List<AIPresetText>> getPresetTexts();
  
  /// 获取默认预设文本
  Future<AIPresetText?> getDefaultPresetText();
  
  /// 保存预设文本
  Future<void> savePresetText(AIPresetText preset);
  
  /// 删除预设文本
  Future<void> deletePresetText(String id);
  
  /// 设置默认预设文本
  Future<void> setDefaultPresetText(String id);
  
  /// 移除默认预设文本
  Future<void> removeDefaultPresetText();
}
