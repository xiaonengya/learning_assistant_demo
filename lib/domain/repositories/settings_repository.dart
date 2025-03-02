import 'package:flutter/material.dart';

/// 设置仓库接口
abstract class SettingsRepository {
  /// 获取深色模式状态
  Future<bool> isDarkMode();
  
  /// 设置深色模式状态
  Future<void> setDarkMode(bool isDark);
  
  /// 获取主题颜色
  Future<Color> getThemeColor();
  
  /// 设置主题颜色
  Future<void> setThemeColor(Color color);
  
  /// 获取主题数据
  Future<ThemeData> getTheme();
  
  /// 保存主题数据
  Future<void> saveTheme(ThemeData theme);
}
