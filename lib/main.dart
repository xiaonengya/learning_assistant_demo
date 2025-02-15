import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/avatar_page.dart';
import 'pages/ai_chat_page.dart';  // 将更新为新的聊天页面
import 'pages/settings_page.dart';  // 将更新为新的设置页面
import 'pages/about_page.dart';  // 添加关于页面的导入
import 'package:shared_preferences/shared_preferences.dart';
import 'services/avatar_service.dart';
import 'dart:io';
import 'services/avatar_state_service.dart';  // Ensure this import is added
import 'services/api_config_service.dart';  // 添加这一行
import 'pages/unified_preset_page.dart';  // 添加这一行
import 'services/storage_service.dart';  // 添加导入

// Main application file
// 主应用程序文件

void main() async {  // 修改为异步
  WidgetsFlutterBinding.ensureInitialized();  // 添加这一行
  
  // 确保存储服务初始化完成
  try {
    final storageService = StorageService();
    await storageService.init();
  } catch (e) {
    print('初始化存储服务失败: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _currentTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  );
  
  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final brightness = prefs.getBool('is_dark_mode') ?? false;
    final colorValue = prefs.getInt('theme_color') ?? Colors.blue.value;
    
    setState(() {
      _currentTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(colorValue),
          brightness: brightness ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      );
    });
  }

  void updateTheme(ThemeData newTheme) async {
    if (!mounted) return;
    
    setState(() => _currentTheme = newTheme);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', newTheme.brightness == Brightness.dark);
    await prefs.setInt('theme_color', newTheme.colorScheme.primary.value);

    // 强制更新所有子部件
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '学习助手',
      theme: _currentTheme,
      home: MainLayout(onThemeChanged: updateTheme),  // 传递主题更新函数
      builder: (context, child) {
        return ScaffoldMessenger(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  final ValueChanged<ThemeData> onThemeChanged;  // 添加主题更新回调

  const MainLayout({
    super.key, 
    required this.onThemeChanged,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // App navigation index / 应用导航索引
  int _selectedIndex = 0;  // 默认选中主页
  
  // Main page list / 主要页面列表
  late final List<Widget> _pages;
  
  // Services for avatar management / 头像管理服务
  final AvatarService _avatarService = AvatarService();
  final AvatarStateService _avatarStateService = AvatarStateService();
  
  // Current avatar image / 当前头像图片
  File? _avatarImage;  // 定义 _avatarImage 变量

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _pages = [
      const HomePage(),
      AIChatPage(),  // 移除 const 因为需要使用新的服务
      const UnifiedPresetPage(), // 使用新的统一预设页面
      SettingsPage(onThemeChanged: widget.onThemeChanged),  // 设置上移
      const AvatarPage(),  // 头像下移
      const AboutPage(),  // 添加关于页面
    ];
    
    // 程序启动时静默应用默认配置
    _applyDefaultConfig();
  }

  Future<void> _applyDefaultConfig() async {
    try {
      final configService = APIConfigService();
      final defaultConfig = await configService.getDefaultConfig();
      if (defaultConfig != null) {
        await configService.saveConfig(defaultConfig);  // 静默应用，不显示提示
      }
    } catch (e) {
      print('应用默认配置失败: $e');
    }
  }

  Future<void> _updateAvatar() async {
    await _avatarService.init();
    final avatar = await _avatarService.getAvatar();
    if (mounted) {
      setState(() {
        _avatarImage = avatar;
        // 强制整个导航栏重建
        _selectedIndex = _selectedIndex;
      });
    }
  }

  Future<void> _loadAvatar() async {
    await _avatarService.init();
    final avatar = await _avatarService.getAvatar();
    if (mounted) {
      setState(() => _avatarImage = avatar);
    }
  }

  // Removed unused _setNewAvatar method

  @override
  Widget build(BuildContext context) {
    return NotificationListener<AvatarUpdateNotification>(
      onNotification: (notification) {
        _updateAvatar();  // 使用新的更新方法
        return true;
      },
      child: Scaffold(
        body: Row(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: constraints.maxHeight,  // 限制容器高度
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(  // 添加滚动支持
                    physics: const ClampingScrollPhysics(),  // 限制滚动范围
                    child: ConstrainedBox(  // 约束最小高度
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        maxHeight: constraints.maxHeight * 1.1, // 限制最大高度
                      ),
                      child: IntrinsicHeight(  // 使内容填充高度
                        child: NavigationRail(
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: (int index) {
                            setState(() => _selectedIndex = index);
                          },
                          leading: Padding(
                            padding: const EdgeInsets.only(top: 8),  // 减小顶部间距
                            child: StreamBuilder<File?>(
                              stream: _avatarStateService.avatarStream,
                              initialData: _avatarImage,
                              builder: (context, snapshot) {
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedIndex = 4),
                                  child: CircleAvatar(
                                    radius: 28,  // 稍微调小头像
                                    backgroundImage: snapshot.data != null 
                                        ? FileImage(snapshot.data!)
                                        : null,
                                    child: snapshot.data == null
                                        ? const Icon(Icons.account_circle, size: 40)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.home_outlined),
                              selectedIcon: Icon(Icons.home),
                              label: Text('主页'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.chat_outlined),
                              selectedIcon: Icon(Icons.chat),
                              label: Text('AI对话'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.format_list_bulleted),
                              selectedIcon: Icon(Icons.format_list_bulleted_sharp),
                              label: Text('预设管理'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.settings_outlined),
                              selectedIcon: Icon(Icons.settings),
                              label: Text('设置'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.account_circle_outlined),
                              selectedIcon: Icon(Icons.account_circle),
                              label: Text('头像'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.info_outline),
                              selectedIcon: Icon(Icons.info),
                              label: Text('关于'),
                              padding: EdgeInsets.only(bottom: 16),
                            ),
                          ],
                          labelType: NavigationRailLabelType.all,
                          minWidth: 72,  // 设置最小宽度
                          groupAlignment: -1,  // 调整对齐方式
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}

// 添加头像更新通知
class AvatarUpdateNotification extends Notification {
  final File avatar;
  AvatarUpdateNotification(this.avatar);
}
