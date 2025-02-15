import 'package:flutter/material.dart';
import '../models/api_config.dart';
import '../services/api_config_service.dart';

final Map<String, List<String>> predefinedModels = {
  'moonshot': ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'],
  'openai': ['gpt-3.5-turbo', 'gpt-4']
};

class APIConfigManagePage extends StatefulWidget {
  const APIConfigManagePage({super.key});

  @override
  State<APIConfigManagePage> createState() => _APIConfigManagePageState();
}

class _APIConfigManagePageState extends State<APIConfigManagePage> {
  final APIConfigService _configService = APIConfigService();
  List<APIConfig> _configs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    setState(() => _isLoading = true);
    final configs = await _configService.loadConfigs();
    if (mounted) {
      setState(() {
        _configs = configs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API 配置管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddConfigDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _configs.length,
        itemBuilder: (context, index) {
          final config = _configs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              leading: Icon(
                config.isDefault ? Icons.star : Icons.settings,
                color: config.isDefault ? Colors.amber : null,
              ),
              title: Text(config.name),
              subtitle: Text(config.model),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('API Key: ${_maskApiKey(config.apiKey)}'),
                      Text('接口地址: ${config.apiEndpoint}'),
                      Text('模型: ${config.model}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _editConfig(config),
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () => _setAsDefault(config),
                            child: const Text('设为默认'),
                          ),
                          TextButton(
                            onPressed: () => _deleteConfig(config),
                            child: const Text('删除'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickSetupDialog,
        tooltip: '快速设置',
        child: const Icon(Icons.flash_on),
      ),
    );
  }

  String _maskApiKey(String apiKey) {
    if (apiKey.length <= 8) return '***';
    return '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}';
  }

  void _showAddConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => _APIConfigDialog(
        onSave: (config) async {
          await _configService.saveConfig(config);
          await _loadConfigs();
        },
      ),
    );
  }

  void _editConfig(APIConfig config) {
    showDialog(
      context: context,
      builder: (context) => _APIConfigDialog(
        config: config,
        onSave: (config) async {
          await _configService.saveConfig(config);
          await _loadConfigs();
        },
      ),
    );
  }

  Future<void> _setAsDefault(APIConfig config) async {
    await _configService.setDefaultConfig(config.id);
    await _loadConfigs();
  }

  Future<void> _deleteConfig(APIConfig config) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除配置 "${config.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _configService.deleteConfig(config.id);
      await _loadConfigs();
    }
  }

  void _showQuickSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('快速设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.rocket_launch),
              title: const Text('Kimi AI'),
              subtitle: const Text('api.moonshot.cn'),
              onTap: () {
                Navigator.pop(context);
                _showAddConfigDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.api),
              title: const Text('OpenAI'),
              subtitle: const Text('api.openai.com'),
              onTap: () {
                Navigator.pop(context);
                _showAddConfigDialog();
              },
            ),
            // 可以添加更多预设选项
          ],
        ),
      ),
    );
  }
}

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
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _endpointController = TextEditingController();
  String _selectedModel = predefinedModels['moonshot']!.first;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.config != null) {
      _nameController.text = widget.config!.name;
      _apiKeyController.text = widget.config!.apiKey;
      _endpointController.text = widget.config!.apiEndpoint;
      _selectedModel = widget.config!.model;
      _isDefault = widget.config!.isDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.config == null ? '添加配置' : '编辑配置'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '配置名称',
                  hintText: '例如: Kimi AI',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入配置名称';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: '以 sk- 开头',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入API Key';
                  }
                  if (!value.startsWith('sk-')) {
                    return 'API Key必须以sk-开头';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _endpointController,
                decoration: const InputDecoration(
                  labelText: 'API接口地址',
                  hintText: '例如: https://api.moonshot.cn/v1',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入API接口地址';
                  }
                  try {
                    final uri = Uri.parse(value);
                    if (!uri.isScheme('http') && !uri.isScheme('https')) {
                      return '请输入有效的HTTP(S)地址';
                    }
                  } catch (_) {
                    return '请输入有效的URL';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedModel,
                decoration: const InputDecoration(
                  labelText: '选择模型',
                ),
                items: predefinedModels.entries.expand((entry) {
                  return [
                    const DropdownMenuItem<String>(
                      enabled: false,
                      value: '',
                      child: Text('── Kimi AI ──'),
                    ),
                    ...entry.value.map((model) => DropdownMenuItem<String>(
                      value: model,
                      child: Text(model),
                    )),
                  ];
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedModel = value);
                  }
                },
              ),
              CheckboxListTile(
                title: const Text('设为默认配置'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value ?? false);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final config = APIConfig(
                id: widget.config?.id ?? DateTime.now().toString(),
                name: _nameController.text,
                apiKey: _apiKeyController.text,
                apiEndpoint: _endpointController.text,
                model: _selectedModel,
                isDefault: _isDefault,
              );
              widget.onSave(config);
              Navigator.pop(context);
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _endpointController.dispose();
    super.dispose();
  }
}
