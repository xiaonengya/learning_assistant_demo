import 'package:flutter/material.dart';
import '../models/api_config.dart';
import '../models/ai_preset_text.dart';
import '../services/api_config_service.dart';
import '../services/ai_preset_text_service.dart';
import '../services/storage_service.dart';

class UnifiedPresetPage extends StatefulWidget {
  const UnifiedPresetPage({super.key});

  @override
  State<UnifiedPresetPage> createState() => _UnifiedPresetPageState();
}

class _UnifiedPresetPageState extends State<UnifiedPresetPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final APIConfigService _configService = APIConfigService();
  final AIPresetTextService _presetService = AIPresetTextService();

  List<APIConfig> _configs = [];
  List<AIPresetText> _presets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAsync();
    _checkConfigs(); // 添加配置检查
  }

  Future<void> _checkConfigs() async {
    try {
      final configs = await _configService.loadConfigs();
      if (configs.isEmpty && mounted) {
        // 如果没有配置,显示快速设置引导
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('开始设置'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('检测到这是首次使用,建议您:'),
                  SizedBox(height: 8),
                  Text('1. 选择一个快速配置模板'),
                  Text('2. 填入您的API密钥'),
                  Text('3. 设为默认配置'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('稍后设置'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showQuickSetupDialog();
                  },
                  child: const Text('开始设置'),
                ),
              ],
            ),
          );
        });
      }
    } catch (e) {
      print('检查配置失败: $e');
    }
  }

  Future<void> _initializeAsync() async {
    try {
      final storageService = StorageService();
      if (!storageService.isInitialized) {
        await storageService.init();
      }
      await _loadAll();
    } catch (e) {
      print('初始化失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('初始化失败: $e')),
        );
      }
    }
  }

  // 加载所有数据
  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadConfigs(),
      _loadPresets(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadConfigs() async {
    final configs = await _configService.loadConfigs();
    if (mounted) setState(() => _configs = configs);
  }

  Future<void> _loadPresets() async {
    final presets = await _presetService.loadPresets();
    if (mounted) setState(() => _presets = presets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabController.index == 0 ? 'API 配置管理' : '对话预设管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.api), text: 'API配置'),
            Tab(icon: Icon(Icons.chat), text: '对话预设'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_tabController.index == 0) {
                _showAddConfigDialog();
              } else {
                _showAddPresetDialog();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConfigList(),
                _buildPresetList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickSetupDialog,
        child: const Icon(Icons.flash_on),
        tooltip: '快速添加',
      ),
    );
  }

  // 构建配置列表
  Widget _buildConfigList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _configs.length,
      itemBuilder: (context, index) {
        final config = _configs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            leading: CircleAvatar(
              backgroundColor: config.isDefault
                  ? Colors.amber.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(
                config.isDefault ? Icons.star : Icons.settings,
                color: config.isDefault ? Colors.amber : null,
              ),
            ),
            title: Text(
              config.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              config.model,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                _buildIconButton(
                  icon: Icons.play_arrow,
                  tooltip: '应用',
                  onPressed: () => _applyConfig(config, showSnackBar: true),
                ),
                _buildIconButton(
                  icon: Icons.edit,
                  tooltip: '编辑',
                  onPressed: () => _editConfig(config),
                ),
                _buildIconButton(
                  icon: Icons.delete,
                  tooltip: '删除',
                  onPressed: () => _deleteConfig(config),
                ),
                _buildIconButton(
                  icon: config.isDefault ? Icons.star : Icons.star_border,
                  color: config.isDefault ? Colors.amber : null,
                  tooltip: config.isDefault ? '取消默认' : '设为默认',
                  onPressed: () => _setConfigAsDefault(config),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      title: 'API Key',
                      value: _maskApiKey(config.apiKey),
                      icon: Icons.key,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      title: '接口地址',
                      value: config.apiEndpoint,
                      icon: Icons.link,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      title: '模型',
                      value: config.model,
                      icon: Icons.psychology,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建预设列表
  Widget _buildPresetList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _presets.length,
      itemBuilder: (context, index) {
        final preset = _presets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              backgroundColor: preset.isDefault
                  ? Colors.amber.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(
                preset.isDefault ? Icons.star : Icons.chat_bubble_outline,
                color: preset.isDefault ? Colors.amber : null,
              ),
            ),
            title: Text(
              preset.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              preset.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                _buildIconButton(
                  icon: Icons.edit,
                  tooltip: '编辑',
                  onPressed: () => _editPreset(preset),
                ),
                _buildIconButton(
                  icon: Icons.delete,
                  tooltip: '删除',
                  onPressed: () => _deletePreset(preset),
                ),
                _buildIconButton(
                  icon: preset.isDefault ? Icons.star : Icons.star_border,
                  color: preset.isDefault ? Colors.amber : null,
                  tooltip: preset.isDefault ? '取消默认' : '设为默认',
                  onPressed: () => _setPresetAsDefault(preset),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Mask API key for display
  String _maskApiKey(String apiKey) {
    if (apiKey.length <= 8) return apiKey;
    return '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}';
  }

  // 构建详情行
  Widget _buildDetailRow({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          '$title：',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  // 构建操作按钮
  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // 修复 API 配置对话框
  void _showAddConfigDialog({APIConfig? initialConfig}) {
    showDialog<APIConfig>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 1000,
          height: 800,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                initialConfig == null ? '添加配置' : '编辑配置',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _APIConfigDialog(
                  config: initialConfig,
                  onSave: (config) => Navigator.of(context).pop(config),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((config) async {
      if (config != null && mounted) {
        try {
          await _configService.saveConfig(config);
          await _loadConfigs();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('保存成功')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('保存失败: $e')),
            );
          }
        }
      }
    });
  }

  // 修复预设对话框
  void _showAddPresetDialog({AIPresetText? initialPreset}) {
    showDialog<AIPresetText>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 1000,
          height: 800,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                initialPreset == null ? '添加预设' : '编辑预设',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _PresetDialog(
                  preset: initialPreset,
                  onSave: (preset) => Navigator.of(context).pop(preset),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((preset) async {
      if (preset != null && mounted) {
        try {
          await _presetService.savePreset(preset);
          await _loadPresets();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('保存成功')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('保存失败: $e')),
            );
          }
        }
      }
    });
  }

  // 编辑预设
  void _editPreset(AIPresetText preset) {
    _showAddPresetDialog(initialPreset: preset);
  }

  void _editConfig(APIConfig config) {
    _showAddConfigDialog(initialConfig: config);
  }

  void _deleteConfig(APIConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('是否确认删除配置 "${config.name}"？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _configService.deleteConfig(config.id);
      await _loadConfigs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    }
  }

  void _deletePreset(AIPresetText preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('是否确认删除预设 "${preset.name}"？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _presetService.deletePreset(preset.id);
      await _loadPresets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    }
  }

  void _setPresetAsDefault(AIPresetText preset) async {
    try {
      if (preset.isDefault) {
        // 如果已经是默认,则取消默认
        await _presetService.removeDefaultPreset();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已取消默认预设')),
          );
        }
      } else {
        // 否则设为默认
        await _presetService.setDefaultPreset(preset.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已将"${preset.name}"设为默认预设')),
          );
        }
      }
      await _loadPresets(); // 重新加载列表以更新UI
    } catch (e) {
      print('设置默认预设失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _applyConfig(APIConfig config, {bool showSnackBar = false}) async {
    await _configService.setDefaultConfig(config.id);
    await _loadConfigs();
    if (mounted && showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已应用"${config.name}"配置')),
      );
    }
  }

  void _setConfigAsDefault(APIConfig config) async {
    try {
      if (config.isDefault) {
        // 如果已经是默认,则取消默认
        await _configService.removeDefaultConfig();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已取消默认配置')),
          );
        }
      } else {
        // 否则设为默认
        await _configService.setDefaultConfig(config.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已将"${config.name}"设为默认配置')),
          );
        }
      }
      await _loadConfigs(); // 重新加载列表以更新UI
    } catch (e) {
      print('设置默认配置失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _showQuickSetupDialog() {
    if (_tabController.index == 0) {
      // API配置快速添加
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('快速添加API配置'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuickConfigItem(
                  title: 'OpenAI',
                  subtitle: '适用于 ChatGPT API',
                  icon: Icons.api,
                  iconColor: Colors.blue,
                  config: APIConfig(
                    id: DateTime.now().toString(),
                    name: 'OpenAI',
                    apiKey: '',
                    apiEndpoint: 'https://api.openai.com/v1',
                    model: 'gpt-3.5-turbo',
                  ),
                ),
                const Divider(),
                _buildQuickConfigItem(
                  title: 'Anthropic Claude',
                  subtitle: '适用于 Claude API',
                  icon: Icons.psychology,
                  iconColor: Colors.purple,
                  config: APIConfig(
                    id: DateTime.now().toString(),
                    name: 'Claude',
                    apiKey: '',
                    apiEndpoint: 'https://api.anthropic.com/v1',
                    model: 'claude-2',
                  ),
                ),
                const Divider(),
                _buildQuickConfigItem(
                  title: 'Kimi AI',
                  subtitle: '适用于 Moonshot API',
                  icon: Icons.rocket_launch,
                  iconColor: Colors.orange,
                  config: APIConfig(
                    id: DateTime.now().toString(),
                    name: 'Kimi',
                    apiKey: '',
                    apiEndpoint: 'https://api.moonshot.cn/v1',
                    model: 'moonshot-v1-8k',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // 预设快速添加
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('快速添加预设'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuickPresetItem(
                  title: '代码助手',
                  subtitle: '编程开发助手',
                  icon: Icons.code,
                  iconColor: Colors.blue,
                  content: '你是一位经验丰富的程序员，请帮我审查和优化代码，给出详细的改进建议。',
                ),
                const Divider(),
                _buildQuickPresetItem(
                  title: '翻译助手',
                  subtitle: '多语言互译',
                  icon: Icons.translate,
                  iconColor: Colors.green,
                  content: '你是一位专业的翻译，请帮我准确翻译内容，保持原文的语气和风格。',
                ),
                const Divider(),
                _buildQuickPresetItem(
                  title: '写作助手',
                  subtitle: '文案创作',
                  icon: Icons.edit_note,
                  iconColor: Colors.orange,
                  content: '你是一位专业的文案撰写者，请帮我优化和改进文章内容，使其更加生动有趣。',
                ),
                const Divider(),
                _buildQuickPresetItem(
                  title: '学习助手',
                  subtitle: '知识讲解',
                  icon: Icons.school,
                  iconColor: Colors.purple,
                  content: '你是一位耐心的老师，请用通俗易懂的方式解释概念，并给出具体的例子。',
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildQuickConfigItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required APIConfig config,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        _showAddConfigDialog(initialConfig: config);
      },
    );
  }

  Widget _buildQuickPresetItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        _showAddPresetDialog(
          initialPreset: AIPresetText(
            id: DateTime.now().toString(),
            name: title,
            content: content,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// 修复配置对话框内容
class _APIConfigDialog extends StatefulWidget {
  final APIConfig? config;
  final Function(APIConfig) onSave;

  const _APIConfigDialog({
    this.config,
    required this.onSave,
  });

  @override
  State<_APIConfigDialog> createState() => _APIConfigDialogState();
}

class _APIConfigDialogState extends State<_APIConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _apiKeyController;
  late TextEditingController _endpointController;
  late TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config?.name ?? '');
    _apiKeyController =
        TextEditingController(text: widget.config?.apiKey ?? '');
    _endpointController =
        TextEditingController(text: widget.config?.apiEndpoint ?? '');
    _modelController = TextEditingController(text: widget.config?.model ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('名称'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? '请输入名称' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: _buildInputDecoration('API Key'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? '请输入API Key' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _endpointController,
                    decoration: _buildInputDecoration('接口地址'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? '请输入接口地址' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modelController,
                    decoration: _buildInputDecoration('模型'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? '请输入模型' : null,
                  ),
                ],
              ),
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: _handleSave,
                child: const Text('保存'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(APIConfig(
        id: widget.config?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        apiKey: _apiKeyController.text,
        apiEndpoint: _endpointController.text,
        model: _modelController.text,
        isDefault: widget.config?.isDefault ?? false,
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _endpointController.dispose();
    _modelController.dispose();
    super.dispose();
  }
}

// 修复预设对话框内容
class _PresetDialog extends StatefulWidget {
  final AIPresetText? preset;
  final Function(AIPresetText) onSave;

  const _PresetDialog({
    this.preset,
    required this.onSave,
  });

  @override
  State<_PresetDialog> createState() => _PresetDialogState();
}

class _PresetDialogState extends State<_PresetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.preset?.name ?? '');
    _contentController =
        TextEditingController(text: widget.preset?.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('名称'),
                  validator: (value) => value?.isEmpty ?? true ? '请输入名称' : null,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextFormField(
                    controller: _contentController,
                    decoration: _buildInputDecoration('内容'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? '请输入内容' : null,
                    maxLines: null,
                    expands: true,
                  ),
                ),
              ],
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: _handleSave,
                child: const Text('保存'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(AIPresetText(
        id: widget.preset?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        content: _contentController.text,
        isDefault: widget.preset?.isDefault ?? false,
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
