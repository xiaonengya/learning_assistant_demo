import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io' show Process;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _easterEggCounter = 0;
  bool _showEasterEgg = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 4,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _easterEggCounter++;
                    if (_easterEggCounter >= 7) {
                      _showEasterEgg = true;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white, // 添加白色背景
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FlutterLogo(
                          size: 48,
                          style: _showEasterEgg ? FlutterLogoStyle.horizontal : FlutterLogoStyle.markOnly,
                          // 移除默认的灰色调
                          textColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '学习助手',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Version 1.0.0',  // 保持版本号不变
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      if (_showEasterEgg)
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 2 * pi),
                          duration: const Duration(seconds: 2),
                          builder: (context, double value, child) {
                            return Transform.rotate(
                              angle: value,
                              child: const Icon(Icons.stars, color: Colors.amber, size: 32),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              ExpansionTile(
                title: const Text('详细信息'),
                initiallyExpanded: true,
                children: [
                  const ListTile(
                    leading: Icon(Icons.person),
                    title: Text('作者'),
                    subtitle: Text('小能'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.flutter_dash),
                    title: Text('开发框架'),
                    subtitle: Text('Flutter 3.27.4'), // 更新 Flutter 版本
                  ),
                  const ListTile(
                    leading: Icon(Icons.code),
                    title: Text('SDK版本'),
                    subtitle: Text('Dart 3.6.2'), // 更新 Dart 版本
                  ),
                  const ListTile(
                    leading: Icon(Icons.grid_view),
                    title: Text('功能特点'),
                    subtitle: Text('''
• AI对话支持
• 自定义API配置
• 预设管理
• 主题定制
• 头像设置'''),
                  ),
                  const ListTile(
                    leading: Icon(Icons.devices),
                    title: Text('支持平台'),
                    subtitle: Text('''
• Android（主要支持）
• Windows/macOS/Linux（未来支持）
• Web（未来支持）'''),
                  ),
                ],
              ),
              const ExpansionTile(
                title: Text('更新日志'),
                children: [
                  ListTile(
                    subtitle: Text('''
v1.0.0 (2025-02)
• 首次发布
• 重构优化
  - 重新设计UI界面
  - 优化对话体验
  - 改进预设系统
• AI对话功能
  - 多模型API支持
  - 预设快速切换
  - 对话历史管理
• 预设管理
  - 快速添加模板
  - 收藏切换功能
  - 预设分类管理
• 系统优化
  - 存储服务重构
  - 状态管理优化
  - 错误处理完善
• 界面适配
  - Material Design 3
  - 深色模式支持
  - 响应式布局优化'''),
                  ),
                ],
              ),
              const Divider(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _showEasterEgg ? Colors.amber.withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      '本软件仅供学习交流使用，请遵守相关法律法规。',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    if (_showEasterEgg) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '❤️ 感谢使用！',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Map<String, String>> getVersionInfo() async {
    try {
      // 这里需要替换为实际获取版本的逻辑
      final flutterVersion = await Process.run('flutter', ['--version']);
      final dartVersion = await Process.run('dart', ['--version']);
      
      String flutterVer = '获取失败';
      String dartVer = '获取失败';
      
      if (flutterVersion.exitCode == 0) {
        final match = RegExp(r'Flutter\s+(\d+\.\d+\.\d+)').firstMatch(flutterVersion.stdout.toString());
        if (match != null) {
          flutterVer = match.group(1) ?? '获取失败';
        }
      }
      
      if (dartVersion.exitCode == 0) {
        final match = RegExp(r'Dart\s+SDK\s+version:\s+(\d+\.\d+\.\d+)').firstMatch(dartVersion.stdout.toString());
        if (match != null) {
          dartVer = match.group(1) ?? '获取失败';
        }
      }
  
      return {
        'flutter': flutterVer,
        'dart': dartVer,
      };
    } catch (e) {
      return {
        'flutter': '获取失败',
        'dart': '获取失败',
      };
    }
  }
}
