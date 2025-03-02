import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../chat/chat_page.dart';
import '../settings/settings_page.dart';
import '../dashboard/dashboard_page.dart'; 
import '../../blocs/avatar/avatar_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/api_config/api_config_bloc.dart';
import '../../blocs/preset/preset_bloc.dart';

// 创建一个全局Key，用于访问HomePage的State
final GlobalKey<_HomePageState> homePageKey = GlobalKey<_HomePageState>();

class HomePage extends StatefulWidget {
  // 使用全局Key
  HomePage({Key? key}) : super(key: key ?? homePageKey);

  // 添加静态方法用于切换页面
  static void switchToChat() {
    homePageKey.currentState?.switchToPage(1);
  }

  static void switchToPage(int index) {
    homePageKey.currentState?.switchToPage(index);
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 使HomePage中的_selectedIndex字段可访问
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    const ChatPage(),
    const SettingsPage(),
  ];

  final List<String> _titles = [
    '主页',
    'AI对话',
    '设置',
  ];

  @override
  void initState() {
    super.initState();
    // 确保页面初始化时加载所有必要数据
    context.read<AvatarBloc>().add(LoadAvatarEvent());
    context.read<ThemeBloc>().add(LoadThemeEvent());
    context.read<ApiConfigBloc>().add(LoadApiConfigsEvent());
    context.read<PresetBloc>().add(LoadPresetsEvent());
  }

  @override
  Widget build(BuildContext context) {
    //final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 2,
        actions: [
          // 头像始终显示
          _buildAvatarWidget(),
        ],
      ),
      drawer: Drawer(
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: _buildDrawer(),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '主页',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '对话',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        BlocBuilder<AvatarBloc, AvatarState>(
          builder: (context, state) {
            return UserAccountsDrawerHeader(
              accountName: const Text('AI学习助手'),
              accountEmail: const Text('让学习更高效'),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedIndex = 2; // 切换到设置页面
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: state is AvatarLoaded && state.avatar != null 
                      ? FileImage(state.avatar!) 
                      : null,
                  child: state is AvatarLoaded && state.avatar == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              decoration: BoxDecoration(
                // 调整暗黑模式下的颜色
                color: isDark 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.7) 
                    : Theme.of(context).colorScheme.primary,
                // 添加渐变效果
                gradient: LinearGradient(
                  colors: isDark 
                      ? [
                          Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ]
                      : [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.primary,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('主页'),
                selected: _selectedIndex == 0,
                selectedColor: Theme.of(context).colorScheme.primary,
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                  Navigator.pop(context); // 关闭抽屉
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('AI对话'),
                selected: _selectedIndex == 1,
                selectedColor: Theme.of(context).colorScheme.primary,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                  Navigator.pop(context); // 关闭抽屉
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.api),
                title: const Text('API配置'),
                onTap: () {
                  Navigator.pop(context); // 关闭抽屉
                  Navigator.pushNamed(context, '/api_configs');
                },
              ),
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text('角色管理'),
                onTap: () {
                  Navigator.pop(context); // 关闭抽屉
                  Navigator.pushNamed(context, '/roles');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('设置'),
                selected: _selectedIndex == 2,
                selectedColor: Theme.of(context).colorScheme.primary,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                  Navigator.pop(context); // 关闭抽屉
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('关于'),
                onTap: () {
                  Navigator.pop(context); // 关闭抽屉
                  Navigator.pushNamed(context, '/about');
                },
              ),
            ],
          ),
        ),
        // 底部切换深色模式
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              final isDark = state.themeData.brightness == Brightness.dark;
              return SwitchListTile(
                title: Text(
                 isDark ? '深色模式' : '浅色模式',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                secondary: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                value: isDark,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ToggleDarkModeEvent(value));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: BlocBuilder<AvatarBloc, AvatarState>(
        builder: (context, state) {
          if (state is AvatarLoaded) {
            return GestureDetector(
              onTap: () {
                // 打开侧边栏
                Scaffold.of(context).openDrawer();
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: state.avatar != null ? FileImage(state.avatar!) : null,
                child: state.avatar == null
                    ? Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
            );
          }
          return IconButton(
            icon: Icon(
              Icons.account_circle,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
    );
  }
  
  // 添加公共方法用于切换页面
  void switchToPage(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
}
