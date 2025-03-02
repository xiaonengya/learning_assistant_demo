import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

/// 获取主题的用例
class GetTheme {
  final SettingsRepository repository;

  GetTheme(this.repository);

  /// 执行用例，获取主题
  Future<ThemeData> call() async {
    return await repository.getTheme();
  }
}

/// 更新主题的用例
class UpdateTheme {
  final SettingsRepository repository;

  UpdateTheme(this.repository);

  /// 执行用例，更新主题
  Future<void> call(ThemeData theme) async {
    await repository.saveTheme(theme);
  }
}

/// 设置深色模式的用例
class SetDarkMode {
  final SettingsRepository repository;

  SetDarkMode(this.repository);

  /// 执行用例，设置深色模式
  Future<void> call(bool isDark) async {
    await repository.setDarkMode(isDark);
  }
}

/// 设置主题颜色的用例
class SetThemeColor {
  final SettingsRepository repository;

  SetThemeColor(this.repository);

  /// 执行用例，设置主题颜色
  Future<void> call(Color color) async {
    await repository.setThemeColor(color);
  }
}
