import 'package:flutter/material.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/local_storage_source.dart';
import '../../core/constants/storage_keys.dart';

/// 设置仓库实现
class SettingsRepositoryImpl implements SettingsRepository {
  final LocalStorageSource _localStorage;
  
  SettingsRepositoryImpl(this._localStorage);

  @override
  Future<bool> isDarkMode() async {
    return _localStorage.getData<bool>(StorageKeys.IS_DARK_MODE) ?? false;
  }

  @override
  Future<void> setDarkMode(bool isDark) async {
    await _localStorage.saveData(StorageKeys.IS_DARK_MODE, isDark);
  }

  @override
  Future<Color> getThemeColor() async {
    final colorValue = _localStorage.getData<int>(StorageKeys.THEME_COLOR);
    return Color(colorValue ?? Colors.blue.value);
  }

  @override
  Future<void> setThemeColor(Color color) async {
    await _localStorage.saveData(StorageKeys.THEME_COLOR, color.value);
  }

  @override
  Future<ThemeData> getTheme() async {
    final isDark = await isDarkMode();
    final primaryColor = await getThemeColor();
    
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  @override
  Future<void> saveTheme(ThemeData theme) async {
    await setDarkMode(theme.brightness == Brightness.dark);
    await setThemeColor(theme.colorScheme.primary);
  }
}
