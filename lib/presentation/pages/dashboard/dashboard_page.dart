import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../blocs/api_config/api_config_bloc.dart';
import '../../blocs/preset/preset_bloc.dart';
import '../home/home_page.dart';  // 导入HomePage以使用静态方法

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Timer _clockTimer;
  String _currentTime = '';
  String _currentDate = '';
  bool _isWifiConnected = false;
  bool _isBluetoothOn = true; // 默认假设开启，因为无法真正检测

  @override
  void initState() {
    super.initState();
    _updateTime();
    _checkConnectivity();
    
    // 每秒更新时间
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
    
    // 监听连接状态变化
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isWifiConnected = result == ConnectivityResult.wifi || 
                          result == ConnectivityResult.ethernet;
      });
    });
  }
  
  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }
  
  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${_padZero(now.hour)}:${_padZero(now.minute)}:${_padZero(now.second)}';
      _currentDate = '${now.year}年${_padZero(now.month)}月${_padZero(now.day)}日';
    });
  }
  
  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
  
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        _isWifiConnected = connectivityResult == ConnectivityResult.wifi ||
                          connectivityResult == ConnectivityResult.ethernet;
        
        // 由于Flutter不提供标准蓝牙状态检查API，我们默认将其设为true
        // 您可以在后续集成真实蓝牙检测库时修改此处
        _isBluetoothOn = true; 
      });
    } catch (e) {
      // 处理错误
    }
  }

  @override
  Widget build(BuildContext context) {
    // 计算屏幕宽度，决定是否使用单列或三列布局
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800; // 宽屏使用三列布局
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部栏: 时钟和连接状态
          _buildTimeAndConnectivityCard(context),
          
          const SizedBox(height: 12), // 减小间距
          
          // 中部区域根据屏幕宽度决定布局 - 使用SizedBox设置固定高度
          if (isWideScreen)
            // 宽屏三列布局 - 减小高度
            SizedBox(
              height: 180, // 减小高度从240到180
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 欢迎卡片
                  Expanded(flex: 5, child: _buildWelcomeCard(context)),
                  const SizedBox(width: 10), // 缩小间距
                  // 快速操作
                  Expanded(flex: 6, child: _buildQuickActions(context)),
                  const SizedBox(width: 10), // 缩小间距
                  // 使用小贴士
                  Expanded(flex: 5, child: _buildTipsCard(context)),
                ],
              ),
            )
          else
            // 窄屏布局 - 减小各卡片高度
            Column(
              children: [
                _buildWelcomeCard(context),
                const SizedBox(height: 12), // 减小间距
                SizedBox(
                  height: 240, // 减小高度
                  child: _buildQuickActions(context)
                ),
                const SizedBox(height: 12), // 减小间距
                SizedBox(
                  height: 160, // 减小高度
                  child: _buildTipsCard(context)
                ),
              ],
            ),
          
          const SizedBox(height: 12), // 减小间距
          
          // 底部: 系统状态
          _buildStatusSection(context),
        ],
      ),
    );
  }

  Widget _buildTimeAndConnectivityCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 数字时钟
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentTime,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentDate,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // WiFi和蓝牙状态
            Row(
              children: [
                Tooltip(
                  message: _isWifiConnected ? '已连接网络' : '未连接网络',
                  child: Icon(
                    _isWifiConnected ? Icons.wifi : Icons.wifi_off,
                    color: _isWifiConnected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Tooltip(
                  message: _isBluetoothOn ? '蓝牙已开启' : '蓝牙未开启',
                  child: Icon(
                    _isBluetoothOn ? Icons.bluetooth : Icons.bluetooth_disabled,
                    color: _isBluetoothOn
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 调整暗黑模式下的渐变颜色
    final gradientColors = isDark 
        ? [
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
            Theme.of(context).colorScheme.secondary.withOpacity(0.7),
          ]
        : [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ];
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero, // 移除外边距
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 减小圆角
      ),
      child: Container(
        padding: const EdgeInsets.all(15), // 减小内边距
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // 减小圆角
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 32, // 减小图标尺寸
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.white,
            ),
            const SizedBox(height: 10), // 减小间距
            Text(
              '欢迎使用AI学习助手',
              style: Theme.of(context).textTheme.titleLarge?.copyWith( // 更小的字体
                color: isDark ? Colors.white.withOpacity(0.9) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4), // 减小间距
            Text(
              '让AI助力您的学习与工作',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith( // 更小的字体
                color: isDark ? Colors.white.withOpacity(0.85) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero, // 移除外边距
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 减小圆角
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 8), // 减小内边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快速操作',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16, // 减小字体大小
              ),
            ),
            const SizedBox(height: 8), // 减小间距
            // 使用Expanded包裹GridView，解决布局约束问题
            Expanded(
              child: GridView.count(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 8, // 减小间距
                crossAxisSpacing: 8, // 减小间距
                childAspectRatio: 3.2, // 减小按钮高度
                children: [
                  // 使用HomePage的静态方法切换到聊天页面
                  _buildActionButton(
                    context,
                    title: '开始对话',
                    icon: Icons.chat,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      // 调用HomePage的静态方法切换到聊天页
                      HomePage.switchToChat();
                    },
                  ),
                  _buildActionButton(
                    context,
                    title: 'API配置',
                    icon: Icons.settings,
                    color: Theme.of(context).colorScheme.tertiary,
                    onTap: () => Navigator.of(context).pushNamed('/api_configs'),
                  ),
                  _buildActionButton(
                    context,
                    title: '角色管理',
                    icon: Icons.psychology,
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () => Navigator.of(context).pushNamed('/roles'),
                  ),
                  _buildActionButton(
                    context,
                    title: '关于',
                    icon: Icons.info_outline,
                    color: Theme.of(context).colorScheme.error,
                    onTap: () => Navigator.of(context).pushNamed('/about'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6), // 减小圆角
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // 减小内边距
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), // 减小圆角
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16, // 减小图标尺寸
              color: color,
            ),
            const SizedBox(width: 6), // 减小间距
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13, // 减小字体大小
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 14, // 减小图标尺寸
              color: color.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '系统状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 改回纵向排列
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // API配置状态
                _buildApiConfigStatus(context),
                const Divider(height: 24),
                // AI角色状态
                _buildRoleStatus(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiConfigStatus(BuildContext context) {
    return BlocBuilder<ApiConfigBloc, ApiConfigState>(
      builder: (context, state) {
        if (state is ApiConfigsLoaded) {
          final hasConfigs = state.configs.isNotEmpty;
          final hasDefaultConfig = state.defaultConfig != null;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 状态图标
              Icon(
                hasConfigs ? Icons.check_circle : Icons.warning,
                color: hasConfigs ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 12),
              
              // 文本信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API配置',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasConfigs 
                        ? '已配置${state.configs.length}个API${hasDefaultConfig ? "\n默认: ${state.defaultConfig!.name}" : ""}'
                        : '未配置API，点击管理添加',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // 管理按钮
              TextButton.icon(
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('管理'),
                onPressed: () {
                  Navigator.of(context).pushNamed('/api_configs');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          );
        }
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildRoleStatus(BuildContext context) {
    return BlocBuilder<PresetBloc, PresetState>(
      builder: (context, state) {
        if (state is PresetsLoaded) {
          final hasRoles = state.roles.isNotEmpty;
          final hasDefaultRole = state.defaultRole != null;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 状态图标
              Icon(
                hasRoles ? Icons.check_circle : Icons.warning,
                color: hasRoles ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 12),
              
              // 文本信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI角色',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasRoles 
                        ? '已配置${state.roles.length}个角色${hasDefaultRole ? "\n默认: ${state.defaultRole!.name}" : ""}'
                        : '未配置角色，点击管理添加',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // 管理按钮
              TextButton.icon(
                icon: const Icon(Icons.psychology, size: 16),
                label: const Text('管理'),
                onPressed: () {
                  Navigator.of(context).pushNamed('/roles');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          );
        }
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero, // 移除外边距
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 减小圆角
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // 减小内边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16, // 减小图标尺寸
                ),
                const SizedBox(width: 6), // 减小间距
                Text(
                  '使用小贴士',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // 减小字体大小
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // 减小间距
            // 将Expanded替换为Flexible
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTipItem(context, icon: Icons.api, tip: '配置API接口以开始对话'),
                  _buildTipItem(context, icon: Icons.psychology, tip: '角色管理可定制AI人格'),
                  _buildTipItem(context, icon: Icons.chat_bubble, tip: '聊天界面可切换API和角色'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(
    BuildContext context, {
    required IconData icon,
    required String tip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0), // 减小间距
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14, // 减小图标尺寸
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 6), // 减小间距
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12, // 减小字体大小
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
