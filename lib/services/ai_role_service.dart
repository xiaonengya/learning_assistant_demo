import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_role.dart';

class AIRoleService {
  static const String _rolesKey = 'ai_roles';
  static final AIRoleService _instance = AIRoleService._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory AIRoleService() => _instance;
  AIRoleService._internal();

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      if (!_prefs.containsKey(_rolesKey)) {
        await _saveRoles(defaultRoles);
      }
      _initialized = true;
    }
  }

  Future<List<AIRole>> loadRoles() async {
    await init();
    final rolesJson = _prefs.getStringList(_rolesKey) ?? [];
    return rolesJson.map((e) => AIRole.fromJson(jsonDecode(e))).toList();
  }

  Future<AIRole?> getDefaultRole() async {
    final roles = await loadRoles();
    return roles.firstWhere(
      (r) => r.isDefault,
      orElse: () => defaultRoles.first,
    );
  }

  Future<void> saveRole(AIRole role) async {
    final roles = await loadRoles();
    final index = roles.indexWhere((r) => r.id == role.id);
    
    if (index >= 0) {
      roles[index] = role;
    } else {
      roles.add(role);
    }

    await _saveRoles(roles);
  }

  Future<void> _saveRoles(List<AIRole> roles) async {
    final rolesJson = roles.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(_rolesKey, rolesJson);
  }
}
