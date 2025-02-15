import 'package:flutter/material.dart';
import '../widgets/theme_settings.dart';
import '../models/api_config.dart';
import '../services/api_config_service.dart';

class SettingsPage extends StatefulWidget {
  final ValueChanged<ThemeData> onThemeChanged;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiConfigService = APIConfigService();
  
  APIConfig _currentConfig = APIConfig(
    id: DateTime.now().toString(),
    name: 'Default Config',
    apiKey: '',
    apiEndpoint: '',
    model: '',
    temperature: 0.7,
  );

  final List<AITemperaturePreset> temperaturePresets = [
    AITemperaturePreset(
      name: '精确模式',
      temperature: 0.2,
      description: '适用于代码生成、数学计算等需要精确答案的场景',
      icon: Icons.precision_manufacturing,
    ),
    AITemperaturePreset(
      name: '平衡模式',
      temperature: 0.7,
      description: '适用于日常对话、问答等一般场景',
      icon: Icons.balance,
    ),
    AITemperaturePreset(
      name: '创意模式',
      temperature: 1.2,
      description: '适用于创意写作、头脑风暴等需要更多创造性的场景',
      icon: Icons.psychology,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await _apiConfigService.getDefaultConfig(); // 改用 getDefaultConfig
      if (config != null && mounted) {
        setState(() => _currentConfig = config);
      }
    } catch (e) {
      print('加载配置失败: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI温度设置', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const Text(
                  'AI温度值影响输出的随机性和创造性。较低的温度值会产生更确定和一致的回答，较高的温度值会产生更有创意和多样的回答。',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: temperaturePresets.map((preset) => 
                    ActionChip(
                      avatar: Icon(preset.icon),
                      label: Text(preset.name),
                      tooltip: preset.description,
                      backgroundColor: _currentConfig.temperature == preset.temperature
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      onPressed: () async {
                        final newConfig = _currentConfig.copyWith(
                          temperature: preset.temperature,
                        );
                        await _apiConfigService.saveConfig(newConfig);
                        setState(() => _currentConfig = newConfig);
                      },
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('温度值：'),
                    Expanded(
                      child: Slider(
                        value: _currentConfig.temperature,
                        min: 0.0,
                        max: 2.0,
                        divisions: 20,
                        label: _currentConfig.temperature.toStringAsFixed(1),
                        onChanged: (value) async {
                          final newConfig = _currentConfig.copyWith(
                            temperature: value,
                          );
                          await _apiConfigService.saveConfig(newConfig);
                          setState(() => _currentConfig = newConfig);
                        },
                      ),
                    ),
                    Text(_currentConfig.temperature.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ThemeSettings(
              currentTheme: Theme.of(context),
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class AITemperaturePreset {
  final String name;
  final double temperature;
  final String description;
  final IconData icon;

  AITemperaturePreset({
    required this.name,
    required this.temperature,
    required this.description,
    required this.icon,
  });
}
