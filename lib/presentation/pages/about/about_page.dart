import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: '学习助手',
    packageName: '',
    version: '1.1.0',
    buildNumber: '2',
    buildSignature: '',
  );
  
  // 彩蛋相关变量
  int _logoTapCount = 0;
  bool _easterEggVisible = false;
  final int _tapThreshold = 5; // 需要点击5次才能触发彩蛋

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = PackageInfo(
          appName: '学习助手',
          packageName: info.packageName,
          version: '1.1.0',
          buildNumber: '2',
          buildSignature: info.buildSignature,
        );
      });
    } catch (e) {
      debugPrint('获取包信息失败: $e');
    }
  }

  // 处理logo点击事件，实现彩蛋
  void _handleLogoTap() {
    setState(() {
      _logoTapCount++;
      if (_logoTapCount >= _tapThreshold && !_easterEggVisible) {
        _easterEggVisible = true;
        _showEasterEggDialog();
      }
    });
  }

  // 显示彩蛋对话框
  void _showEasterEggDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 你发现了彩蛋！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/easter_egg.jpg', 
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.celebration, size: 60, color: Colors.amber),
            ),
            const SizedBox(height: 16),
            const Text(
              '恭喜你发现了隐藏彩蛋！\n\n'
              '小能想说：感谢你使用学习助手，希望它能成为你学习路上的得力助手！\n\n'
              '愿知识的力量与你同在！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('太棒了！'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于应用'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          
          // 应用图标和名称 - 添加点击事件用于彩蛋
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _handleLogoTap,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    child: _easterEggVisible 
                      ? const Icon(
                          Icons.auto_awesome,
                          size: 60,
                          color: Colors.amber,
                        )
                      : Icon(
                          Icons.school,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '学习助手',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '版本 ${_packageInfo.version} (${_packageInfo.buildNumber})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Copyright © 2025 小能 保留所有权利',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 应用信息 - 确保这里的版本号也正确
          const _Section(
            title: '应用信息',
            children: [
              _InfoRow(title: '版本', value: '1.1.0'),
              _InfoRow(title: '更新日期', value: '2025年3月'),
              _InfoRow(title: '开发语言', value: 'Flutter/Dart'),
              _InfoRow(title: '许可证', value: 'GNU GPL v3.0'),
            ],
          ),
          
          const _Section(
            title: '架构升级',
            children: [
              _Feature(
                title: '干净架构重构', 
                description: '采用领域驱动设计和干净架构重构整个应用，实现业务逻辑与UI的解耦，提高代码可维护性'
              ),
              _Feature(
                title: '状态管理优化', 
                description: '重新设计Bloc状态管理流程，确保温度设置等功能能够实时反映在应用中，避免状态闪烁问题'
              ),
              _Feature(
                title: '模块化设计', 
                description: '实现高内聚低耦合的模块化设计，使各功能组件可以独立开发和测试'
              ),
            ],
          ),
          
          const _Section(
            title: '功能增强',
            children: [
              _Feature(
                title: 'API温度精确控制', 
                description: '优化温度控制功能，使其直接与API预设关联，为不同场景提供个性化响应调整'
              ),
              _Feature(
                title: '智能主页工具集', 
                description: '新增主页实用工具集，提供学习辅助功能和快速访问选项'
              ),
              _Feature(
                title: '响应式界面', 
                description: '改进用户界面的响应性和流畅度，适配多种设备屏幕大小'
              ),
            ],
          ),
          
          const _Section(
            title: '开发者',
            children: [
              _InfoRow(title: '作者', value: '小能'),
              _InfoRow(title: '邮箱', value: 'ckl1234512345@outlook.com'),
              _InfoRow(title: 'GitHub', value: 'xiaonengya'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 按钮区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.code),
                    label: const Text('GitHub仓库'),
                    onPressed: () => _launchUrl('https://github.com/xiaonengya/learning_assistant_demo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.description),
                    label: const Text('许可证'),
                    onPressed: () => _showLicenseDialog(context),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),

          // 添加隐藏的开发者笔记区域，只有在彩蛋被触发后显示
          if (_easterEggVisible)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔐 开发者笔记',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Divider(),
                      Text(
                        '亲爱的使用者：\n\n'
                        '开发这款应用的灵感来源于我自己在学习过程中的需求。AI技术日新月异，'
                        '但实用的学习辅助工具却不够便捷。希望这款应用能成为你知识探索的一个小伙伴。\n\n'
                        '未来计划添加更多功能：\n'
                        '✓ 多模态交互支持\n'
                        '✓ 学习进度追踪\n'
                        '✓ 知识图谱生成\n'
                        '✓ 协作学习功能\n\n'
                        '如果你有任何想法或建议，欢迎随时联系我！\n\n'
                        '— 小能',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开链接')),
      );
    }
  }

  void _showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GNU GPL v3.0 许可证'),
        content: const SingleChildScrollView(
          child: Text(
            'AI学习助手是基于GNU通用公共许可证(GPL)第3版发布的自由软件。\n\n'
            '您可以自由地使用、修改和分享本软件，但任何修改后的版本必须同样基于GPL许可证开源。\n\n'
            '本软件不提供任何明示或暗示的担保。详情请参阅完整的GPL许可证文本。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () => _launchUrl('https://www.gnu.org/licenses/gpl-3.0.html'),
            child: const Text('查看完整许可证'),
          ),
        ],
      ),
    );
  }
}

// 辅助组件: 信息部分
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _Section({
    required this.title,
    required this.children,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          ...children,
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// 辅助组件: 信息行
class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  
  const _InfoRow({
    required this.title,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

// 辅助组件: 功能项
class _Feature extends StatelessWidget {
  final String title;
  final String description;
  
  const _Feature({
    required this.title,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}