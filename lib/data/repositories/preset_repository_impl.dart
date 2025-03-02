import '../../core/constants/storage_keys.dart';
import '../../domain/models/ai_preset_text.dart';
import '../../domain/models/ai_role.dart';
import '../../domain/repositories/preset_repository.dart';
import '../datasources/local/local_storage_source.dart';

class PresetRepositoryImpl implements PresetRepository {
  final LocalStorageSource _localStorage;
  
  PresetRepositoryImpl(this._localStorage);
  
  // 角色相关实现
  @override
  Future<List<AIRole>> getRoles() async {
    try {
      // 从本地存储获取角色列表
      final rolesJson = _localStorage.getData<List<dynamic>>(StorageKeys.AI_ROLES);
      
      if (rolesJson == null || rolesJson.isEmpty) {
        // 返回默认角色列表
        await _saveDefaultRoles();
        return defaultRoles;
      }
      
      // 解析角色列表
      final roles = rolesJson
          .map((json) => AIRole.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return roles;
    } catch (e) {
      // 如果解析失败，返回默认角色列表
      await _saveDefaultRoles();
      return defaultRoles;
    }
  }

  @override
  Future<AIRole?> getDefaultRole() async {
    try {
      // 获取默认角色ID
      final defaultRoleId = _localStorage.getData<String>(StorageKeys.DEFAULT_ROLE);
      if (defaultRoleId == null) {
        // 如果没有默认角色ID，返回预定义的默认角色
        final roles = await getRoles();
        final defaultRole = roles.firstWhere(
          (role) => role.isDefault, 
          orElse: () => roles.first,
        );
        return defaultRole;
      }
      
      // 根据ID获取默认角色
      final roles = await getRoles();
      final defaultRole = roles.firstWhere(
        (role) => role.id == defaultRoleId,
        orElse: () => roles.firstWhere(
          (role) => role.isDefault,
          orElse: () => roles.first,
        ),
      );
      
      return defaultRole;
    } catch (e) {
      // 如果出现错误，返回null
      return null;
    }
  }

  @override
  Future<void> saveRole(AIRole role) async {
    // 获取当前角色列表
    final roles = await getRoles();
    
    // 检查是否存在相同ID的角色
    final index = roles.indexWhere((r) => r.id == role.id);
    
    if (index >= 0) {
      // 更新现有角色
      roles[index] = role;
    } else {
      // 添加新角色
      roles.add(role);
    }
    
    // 保存角色列表
    final rolesJson = roles.map((r) => r.toJson()).toList();
    await _localStorage.saveData(StorageKeys.AI_ROLES, rolesJson);
    
    // 如果是默认角色，设置默认角色ID
    if (role.isDefault) {
      await setDefaultRole(role.id);
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    // 获取当前角色列表
    final roles = await getRoles();
    
    // 移除指定ID的角色
    roles.removeWhere((r) => r.id == id);
    
    // 保存更新后的角色列表
    final rolesJson = roles.map((r) => r.toJson()).toList();
    await _localStorage.saveData(StorageKeys.AI_ROLES, rolesJson);
    
    // 检查被删除的角色是否是默认角色
    final defaultRoleId = _localStorage.getData<String>(StorageKeys.DEFAULT_ROLE);
    if (defaultRoleId == id) {
      // 如果删除的是默认角色，需要重置默认角色
      if (roles.isNotEmpty) {
        await setDefaultRole(roles.first.id);
      } else {
        await _localStorage.removeData(StorageKeys.DEFAULT_ROLE);
      }
    }
  }

  @override
  Future<void> setDefaultRole(String id) async {
    // 设置默认角色ID
    await _localStorage.saveData(StorageKeys.DEFAULT_ROLE, id);
    
    // 更新角色列表中的默认标志
    final roles = await getRoles();
    for (var i = 0; i < roles.length; i++) {
      if (roles[i].id == id) {
        roles[i] = AIRole(
          id: roles[i].id,
          name: roles[i].name,
          description: roles[i].description,
          systemPrompt: roles[i].systemPrompt,
          category: roles[i].category,
          isDefault: true,
          createdAt: roles[i].createdAt,
        );
      } else if (roles[i].isDefault) {
        roles[i] = AIRole(
          id: roles[i].id,
          name: roles[i].name,
          description: roles[i].description,
          systemPrompt: roles[i].systemPrompt,
          category: roles[i].category,
          isDefault: false,
          createdAt: roles[i].createdAt,
        );
      }
    }
    
    // 保存更新后的角色列表
    final rolesJson = roles.map((r) => r.toJson()).toList();
    await _localStorage.saveData(StorageKeys.AI_ROLES, rolesJson);
  }
  
  // 预设文本相关实现
  @override
  Future<List<AIPresetText>> getPresetTexts() async {
    try {
      // 从本地存储获取预设文本列表
      final presetsJson = _localStorage.getData<List<dynamic>>(StorageKeys.AI_PRESET_TEXTS);
      
      if (presetsJson == null || presetsJson.isEmpty) {
        return [];
      }
      
      // 解析预设文本列表
      final presets = presetsJson
          .map((json) => AIPresetText.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return presets;
    } catch (e) {
      // 如果解析失败，返回空列表
      return [];
    }
  }

  @override
  Future<AIPresetText?> getDefaultPresetText() async {
    try {
      // 获取默认预设文本ID
      final defaultPresetId = _localStorage.getData<String>(StorageKeys.DEFAULT_PRESET_TEXT);
      if (defaultPresetId == null) {
        // 如果没有默认预设文本ID，返回null
        return null;
      }
      
      // 根据ID获取默认预设文本
      final presets = await getPresetTexts();
      if (presets.isEmpty) {
        return null;
      }
      
      final defaultPreset = presets.firstWhere(
        (preset) => preset.id == defaultPresetId,
        orElse: () => presets.firstWhere(
          (preset) => preset.isDefault,
          orElse: () => presets.first,
        ),
      );
      
      return defaultPreset;
    } catch (e) {
      // 如果出现错误，返回null
      return null;
    }
  }

  @override
  Future<void> savePresetText(AIPresetText preset) async {
    // 获取当前预设文本列表
    final presets = await getPresetTexts();
    
    // 检查是否存在相同ID的预设文本
    final index = presets.indexWhere((p) => p.id == preset.id);
    
    if (index >= 0) {
      // 更新现有预设文本
      presets[index] = preset;
    } else {
      // 添加新预设文本
      presets.add(preset);
    }
    
    // 保存预设文本列表
    final presetsJson = presets.map((p) => p.toJson()).toList();
    await _localStorage.saveData(StorageKeys.AI_PRESET_TEXTS, presetsJson);
    
    // 如果是默认预设文本，设置默认预设文本ID
    if (preset.isDefault) {
      await setDefaultPresetText(preset.id);
    }
  }

  @override
  Future<void> deletePresetText(String id) async {
    // 获取当前预设文本列表
    final presets = await getPresetTexts();
    
    // 移除指定ID的预设文本
    presets.removeWhere((p) => p.id == id);
    
    // 保存更新后的预设文本列表
    final presetsJson = presets.map((p) => p.toJson()).toList();
    await _localStorage.saveData(StorageKeys.AI_PRESET_TEXTS, presetsJson);
    
    // 检查被删除的预设文本是否是默认预设文本
    final defaultPresetId = _localStorage.getData<String>(StorageKeys.DEFAULT_PRESET_TEXT);
    if (defaultPresetId == id) {
      // 如果删除的是默认预设文本，移除默认预设文本ID
      await removeDefaultPresetText();
    }
  }

  @override
  Future<void> setDefaultPresetText(String id) async {
    // 设置默认预设文本ID
    await _localStorage.saveData(StorageKeys.DEFAULT_PRESET_TEXT, id);
    
    // 更新预设文本列表中的默认标志
    final presets = await getPresetTexts();
    for (var i = 0; i < presets.length; i++) {
      if (presets[i].id == id) {
        presets[i] = AIPresetText(
          id: presets[i].id,
          name: presets[i].name,
          content: presets[i].content,
          isDefault: true,
        );
      } else if (presets[i].isDefault) {
        presets[i] = AIPresetText(
          id: presets[i].id,
          name: presets[i].name,
          content: presets[i].content,
          isDefault: false,
        );
      }
    }
    
    // 保存更新后的预设文本列表
    final presetsJson = presets.map((p) => p.toJson()).toList();
    await _localStorage.saveData(StorageKeys.AI_PRESET_TEXTS, presetsJson);
  }

  @override
  Future<void> removeDefaultPresetText() async {
    // 移除默认预设文本ID
    await _localStorage.removeData(StorageKeys.DEFAULT_PRESET_TEXT);
    
    // 更新预设文本列表中的默认标志
    final presets = await getPresetTexts();
    for (var i = 0; i < presets.length; i++) {
      if (presets[i].isDefault) {
        presets[i] = AIPresetText(
          id: presets[i].id,
          name: presets[i].name,
          content: presets[i].content,
          isDefault: false,
        );
      }
    }
    
    // 保存更新后的预设文本列表
    final presetsJson = presets.map((p) => p.toJson()).toList();
    await _localStorage.saveData(StorageKeys.AI_PRESET_TEXTS, presetsJson);
  }
  
  // 私有帮助方法
  Future<void> _saveDefaultRoles() async {
    final rolesJson = defaultRoles.map((r) => r.toJson()).toList();
    await _localStorage.saveData(StorageKeys.AI_ROLES, rolesJson);
    
    // 设置默认角色
    final defaultRole = defaultRoles.firstWhere(
      (role) => role.isDefault,
      orElse: () => defaultRoles.first,
    );
    await _localStorage.saveData(StorageKeys.DEFAULT_ROLE, defaultRole.id);
  }
}
