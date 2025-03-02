import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/avatar/avatar_bloc.dart';
import '../../blocs/api_config/api_config_bloc.dart';
import '../../../domain/models/api_config.dart'; // 确保导入APIConfig

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _temperature = 0.7;
  final _imagePicker = ImagePicker();
  // 添加缓存变量
  APIConfig? _lastValidConfig;

  @override
  void initState() {
    super.initState();
    _loadTemperatureFromDefaultConfig();
    context.read<AvatarBloc>().add(LoadAvatarEvent());
  }

  void _loadTemperatureFromDefaultConfig() {
    final apiConfigState = context.read<ApiConfigBloc>().state;
    if (apiConfigState is ApiConfigsLoaded && apiConfigState.defaultConfig != null) {
      setState(() {
        _temperature = apiConfigState.defaultConfig!.temperature;
        _lastValidConfig = apiConfigState.defaultConfig; // 初始化缓存
      });
    }
  }

  void _saveTemperatureToDefaultConfig(double value) {
    final apiConfigState = context.read<ApiConfigBloc>().state;
    if (apiConfigState is ApiConfigsLoaded && apiConfigState.defaultConfig != null) {
      final updatedConfig = apiConfigState.defaultConfig!.copyWith(
        temperature: value,
      );
      
      _lastValidConfig = updatedConfig; // 更新缓存
      context.read<ApiConfigBloc>().add(SaveApiConfigEvent(updatedConfig));
    }
  }

  // 从avatar_picker.dart整合的选择头像方法
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      
      if (pickedFile != null && mounted) {
        context.read<AvatarBloc>().add(UpdateAvatarEvent(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  // 从avatar_picker.dart整合的显示选择器方法
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动条
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // 标题
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '选择头像',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('拍照'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('从相册选择'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          
          BlocBuilder<AvatarBloc, AvatarState>(
            builder: (context, state) {
              if (state is AvatarLoaded && state.avatar != null) {
                return ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('删除当前头像', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AvatarBloc>().add(DeleteAvatarEvent());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApiConfigBloc, ApiConfigState>(
      listener: (context, state) {
        if (state is ApiConfigsLoaded && state.defaultConfig != null) {
          setState(() {
            _temperature = state.defaultConfig!.temperature;
            _lastValidConfig = state.defaultConfig; // 更新缓存
          });
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 温度设置区块
            _buildTemperatureSection(),
            
            const SizedBox(height: 24),
            
            // 头像设置区块 
            _buildAvatarSection(),
            
            const SizedBox(height: 24),
            
            // 主题设置
            _buildThemeSection(),
            
            const SizedBox(height: 24),
            
            // 关于应用
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  // 新添加的温度设置区块
  Widget _buildTemperatureSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.thermostat,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI回复温度',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '温度控制AI回复的创造性和随机性。较低的值使回复更加确定和精确，较高的值则更加多样化和创造性。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '推荐值: 学术/编程问题 0.1-0.5, 创意写作/头脑风暴 0.7-1.2, 角色扮演/讲故事 1.0-2.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // 显示当前配置名称 - 使用缓存避免闪烁
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _lastValidConfig != null
                ? Text(
                    '当前修改: ${_lastValidConfig!.name}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : BlocBuilder<ApiConfigBloc, ApiConfigState>(
                    builder: (context, state) {
                      if (state is ApiConfigsLoaded && state.defaultConfig != null) {
                        // 如果状态中有有效配置但缓存为空，更新缓存
                        if (_lastValidConfig == null) {
                          _lastValidConfig = state.defaultConfig;
                        }
                        return Text(
                          '当前修改: ${state.defaultConfig!.name}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }
                      return Text(
                        '请先在API配置页面设置默认配置',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      );
                    },
                  ),
            ),
            
            Row(
              children: [
                const Text('精确'),
                Expanded(
                  child: Slider(
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    value: _temperature,
                    onChanged: (value) {
                      setState(() {
                        _temperature = value;
                      });
                      _saveTemperatureToDefaultConfig(value);
                    },
                  ),
                ),
                const Text('创造性'),
              ],
            ),
            Center(
              child: Text(
                '温度: ${_temperature.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 从avatar_picker.dart整合的头像设置区块
  Widget _buildAvatarSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '个人头像',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                BlocBuilder<AvatarBloc, AvatarState>(
                  builder: (context, state) {
                    Widget avatarWidget;
                    
                    if (state is AvatarLoading) {
                      avatarWidget = const CircularProgressIndicator();
                    } else if (state is AvatarLoaded) {
                      avatarWidget = GestureDetector(
                        onTap: _showPickerOptions,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          backgroundImage: state.avatar != null ? FileImage(state.avatar!) : null,
                          child: Stack(
                            children: [
                              if (state.avatar == null)
                                Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      avatarWidget = GestureDetector(
                        onTap: _showPickerOptions,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          child: const Icon(Icons.person, size: 40),
                        ),
                      );
                    }
                    
                    return avatarWidget;
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '个人头像',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      const Text('设置您的个人头像，让AI更了解您'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('修改头像'),
                        onPressed: _showPickerOptions,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 以下是现有代码的简化保留部分
  Widget _buildThemeSection() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.color_lens,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '外观',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('深色模式'),
                  subtitle: const Text('启用深色主题'),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    // 假设这个方法是用来切换深色主题的
                    context.read<ThemeBloc>().add(ToggleDarkModeEvent(value));
                  },
                ),
                const SizedBox(height: 16),
                const Text('主题颜色'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal,
                    Colors.pink,
                    Colors.indigo,
                  ].map((color) {
                    final isSelected = color.value == state.colorSeed.value;
                    return GestureDetector(
                      onTap: () {
                        context.read<ThemeBloc>().add(ChangeColorEvent(color));
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '关于应用',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '本应用不会收集任何个人数据。所有配置和对话历史均存储在本地设备上。\n\n'
              '您输入的API密钥仅用于与相应AI服务提供商的通信，不会被发送到其他地方。\n\n'
              '我们重视您的隐私，并致力于保护您的个人数据安全。',
            ),
          ],
        ),
      ),
    );
  }
}
