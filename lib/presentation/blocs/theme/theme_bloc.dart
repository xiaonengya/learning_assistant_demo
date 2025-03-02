import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/theme_usecases.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {}

// 确保这两个事件类存在于theme_bloc.dart中
class ChangeColorEvent extends ThemeEvent {
  final Color color;
  
  const ChangeColorEvent(this.color);
  
  @override
  List<Object> get props => [color];
}

class ToggleDarkModeEvent extends ThemeEvent {
  final bool isDarkMode;
  
  const ToggleDarkModeEvent(this.isDarkMode);
  
  @override
  List<Object> get props => [isDarkMode];
}

// States
class ThemeState extends Equatable {
  final ThemeData themeData;
  final Color colorSeed;
  final bool isDark; // 添加isDark属性
  
  const ThemeState({
    required this.themeData,
    required this.colorSeed,
    required this.isDark, // 初始化isDark属性
  });
  
  @override
  List<Object> get props => [themeData, colorSeed, isDark];
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final GetTheme getTheme;
  final UpdateTheme updateTheme;
  final SetDarkMode setDarkMode;
  final SetThemeColor setThemeColor;
  
  ThemeBloc({
    required this.getTheme,
    required this.updateTheme,
    required this.setDarkMode,
    required this.setThemeColor,
  }) : super(ThemeState(
         themeData: ThemeData.light(),
         colorSeed: Colors.blue,
         isDark: false, // 初始化isDark属性
       )) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeColorEvent>(_onChangeColor);
    on<ToggleDarkModeEvent>(_onToggleDarkMode);
  }
  
  Future<void> _onToggleDarkMode(
    ToggleDarkModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      await setDarkMode(event.isDarkMode);
      
      // 创建基于颜色种子的配色方案
      final colorScheme = ColorScheme.fromSeed(
        seedColor: state.colorSeed,
        brightness: event.isDarkMode ? Brightness.dark : Brightness.light,
      );
      
      // 更新主题数据
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        brightness: event.isDarkMode ? Brightness.dark : Brightness.light,
      );
      
      // 发出包含isDark属性的更新状态
      emit(ThemeState(
        themeData: themeData,
        colorSeed: state.colorSeed,
        isDark: event.isDarkMode, // 更新isDark属性
      ));
    } catch (e) {
      // 错误处理保持状态不变
    }
  }
  
  Future<void> _onChangeColor(
    ChangeColorEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      await setThemeColor(event.color);
      
      // 创建基于新颜色种子的配色方案
      final colorScheme = ColorScheme.fromSeed(
        seedColor: event.color,
        brightness: state.isDark ? Brightness.dark : Brightness.light,
      );
      
      // 更新主题数据
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        brightness: state.isDark ? Brightness.dark : Brightness.light,
      );
      
      // 发出更新状态
      emit(ThemeState(
        themeData: themeData,
        colorSeed: event.color,
        isDark: state.isDark, // 保持isDark值不变
      ));
    } catch (e) {
      // 错误处理保持状态不变
    }
  }
  
  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final themeData = await getTheme();
      final isDark = themeData.brightness == Brightness.dark;
      final colorSeed = themeData.colorScheme.primary;
      
      emit(ThemeState(
        themeData: themeData,
        colorSeed: colorSeed,
        isDark: isDark, // 设置isDark属性
      ));
    } catch (e) {
      // 错误处理使用默认状态
      emit(ThemeState(
        themeData: ThemeData.light(),
        colorSeed: Colors.blue,
        isDark: false,
      ));
    }
  }
}
