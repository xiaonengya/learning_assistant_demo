import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// 主题设置模型
class ThemeSettings extends Equatable {
  /// 主题颜色
  final Color? color;
  
  /// 是否为深色模式
  final bool? isDarkMode;

  const ThemeSettings({
    this.color,
    this.isDarkMode,
  });

  /// 创建副本并更新指定的字段
  ThemeSettings copyWith({
    Color? color,
    bool? isDarkMode,
  }) {
    return ThemeSettings(
      color: color ?? this.color,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [color?.value, isDarkMode];
}
