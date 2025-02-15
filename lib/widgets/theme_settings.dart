import 'package:flutter/material.dart';

class ThemeSettings extends StatefulWidget {
  final ThemeData currentTheme;
  final ValueChanged<ThemeData> onThemeChanged;

  const ThemeSettings({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  final List<ThemePreset> commonPresets = [
    ThemePreset(
      "经典蓝",
      const Color(0xFF1976D2),
      "专业稳重的经典蓝色调",
    ),
    ThemePreset(
      "翡翠绿",
      const Color(0xFF2E7D32),
      "清新自然的森林色调",
    ),
    ThemePreset(
      "珊瑚橙",
      const Color(0xFFFF7043),
      "充满活力的暖色调",
    ),
    ThemePreset(
      "优雅紫",
      const Color(0xFF7B1FA2),
      "高贵典雅的紫罗兰",
    ),
    ThemePreset(
      "薄荷青",
      const Color(0xFF00897B),
      "清爽怡人的薄荷色",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 深色模式切换
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            title: Text(
              isDark ? '深色模式' : '浅色模式',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: _toggleDarkMode,
            ),
          ),
        ),
        // 颜色主题选择
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            '主题颜色',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var preset in commonPresets)
              _buildColorButton(
                preset,
                isSelected: preset.color.value == currentColor.value,
              ),
          ],
        ),
      ],
    );
  }

  void _toggleDarkMode(bool isDark) {
    final currentColorScheme = Theme.of(context).colorScheme;
    final newTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: currentColorScheme.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
    );
    widget.onThemeChanged(newTheme);
  }

  Widget _buildColorButton(ThemePreset preset, {bool isSelected = false}) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 8 : 0,
      child: InkWell(
        onTap: () => _applyThemeColor(preset.color),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: preset.color.withOpacity(0.1),
            border: Border.all(
              color: preset.color.withOpacity(isSelected ? 1 : 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: preset.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                preset.name,
                style: TextStyle(
                  color: preset.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                preset.description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyThemeColor(Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
    );
    widget.onThemeChanged(newTheme);
  }
}

class ThemePreset {
  final String name;
  final Color color;
  final String description;

  ThemePreset(this.name, this.color, this.description);
}
