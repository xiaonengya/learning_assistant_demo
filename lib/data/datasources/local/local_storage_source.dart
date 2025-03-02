import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 本地存储数据源接口
abstract class LocalStorageSource {
  /// 保存数据
  Future<void> saveData<T>(String key, T value);
  
  /// 获取数据
  T? getData<T>(String key);
  
  /// 删除数据
  Future<void> removeData(String key);
  
  /// 清空所有数据
  Future<void> clearAll();
}

/// 基于SharedPreferences的本地存储实现
class SharedPreferencesSource implements LocalStorageSource {
  final SharedPreferences _prefs;
  
  SharedPreferencesSource(this._prefs);

  @override
  Future<void> saveData<T>(String key, T value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      // 对于其他类型，尝试转换为JSON
      final jsonString = jsonEncode(value);
      await _prefs.setString(key, jsonString);
    }
  }

  @override
  T? getData<T>(String key) {
    if (!_prefs.containsKey(key)) return null;
    
    if (T == String) {
      return _prefs.getString(key) as T?;
    } else if (T == int) {
      return _prefs.getInt(key) as T?;
    } else if (T == bool) {
      return _prefs.getBool(key) as T?;
    } else if (T == double) {
      return _prefs.getDouble(key) as T?;
    } else if (T == List<String>) {
      return _prefs.getStringList(key) as T?;
    } else {
      // 对于其他类型，尝试从JSON转换
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      
      try {
        final value = jsonDecode(jsonString);
        return value as T?;
      } catch (e) {
        // 转换失败，返回null
        return null;
      }
    }
  }

  @override
  Future<void> removeData(String key) async {
    if (_prefs.containsKey(key)) {
      await _prefs.remove(key);
    }
  }

  @override
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
