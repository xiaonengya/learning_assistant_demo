import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/api_config/api_config_bloc.dart';
import '../../../domain/models/api_config.dart';
import '../../widgets/common/loading_indicator.dart';

class ApiConfigPage extends StatelessWidget {
  const ApiConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API配置管理'),
      ),
      body: BlocConsumer<ApiConfigBloc, ApiConfigState>(
        listener: (context, state) {
          if (state is ApiConfigError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ApiConfigLoading) {
            return const LoadingIndicator(message: '加载API配置中...');
          } else if (state is ApiConfigsLoaded) {
            return _buildConfigList(context, state);
          } else {
            return const Center(
              child: Text('加载失败，请重试'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        tooltip: '添加新API配置',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildConfigList(BuildContext context, ApiConfigsLoaded state) {
    if (state.configs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            const Text('暂无API配置'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('添加配置'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.configs.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final config = state.configs[index];
        final isDefault = config.id == state.defaultConfig?.id;

        return Card(
          elevation: isDefault ? 4 : 1,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isDefault
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Row(
              children: [
                Text(
                  config.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isDefault)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: const Text('默认'),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('端点: ${config.apiEndpoint}'),
                const SizedBox(height: 2),
                Text('模型: ${config.model}'),
                const SizedBox(height: 2),
                Text('温度: ${config.temperature}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.star,
                    color: isDefault ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  tooltip: isDefault ? '默认配置' : '设为默认',
                  onPressed: isDefault
                      ? null
                      : () {
                          context.read<ApiConfigBloc>().add(
                                SetDefaultApiConfigEvent(config.id),
                              );
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: '编辑',
                  onPressed: () => _showAddEditDialog(context, config),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: '删除',
                  onPressed: () => _confirmDelete(context, config),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, APIConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除配置'),
        content: Text('确定要删除配置 "${config.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ApiConfigBloc>().add(
                    DeleteApiConfigEvent(config.id),
                  );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, [APIConfig? config]) {
    showDialog(
      context: context,
      builder: (context) => ApiConfigDialog(
        config: config,
        onSave: (newConfig) {
          context.read<ApiConfigBloc>().add(
                SaveApiConfigEvent(newConfig),
              );
        },
      ),
    );
  }
}

class ApiConfigDialog extends StatefulWidget {
  final APIConfig? config;
  final Function(APIConfig) onSave;

  const ApiConfigDialog({
    super.key,
    this.config,
    required this.onSave,
  });

  @override
  State<ApiConfigDialog> createState() => _ApiConfigDialogState();
}

class _ApiConfigDialogState extends State<ApiConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _endpointController = TextEditingController();
  final _modelController = TextEditingController();
  double _temperature = 0.7;
  bool _isDefault = false;

  // 预定义的模型和端点选项
  final Map<String, String> _predefinedEndpoints = {
    'OpenAI': 'https://api.openai.com/v1',
    'Kimi': 'https://api.moonshot.cn/v1',
    'Claude': 'https://api.anthropic.com/v1',
  };

  final Map<String, List<String>> _predefinedModels = {
    'OpenAI': ['gpt-3.5-turbo', 'gpt-4', 'gpt-4-turbo'],
    'Kimi': ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'],
    'Claude': ['claude-3-opus-20240229', 'claude-3-sonnet-20240229', 'claude-3-haiku-20240307'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.config != null) {
      _nameController.text = widget.config!.name;
      _apiKeyController.text = widget.config!.apiKey;
      _endpointController.text = widget.config!.apiEndpoint;
      _modelController.text = widget.config!.model;
      _temperature = widget.config!.temperature;
      _isDefault = widget.config!.isDefault;
    } else {
      // 默认为OpenAI
      _endpointController.text = _predefinedEndpoints['OpenAI']!;
      _modelController.text = _predefinedModels['OpenAI']![0];
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

  String? _getProviderFromEndpoint(String endpoint) {
    for (final entry in _predefinedEndpoints.entries) {
      if (endpoint == entry.value || endpoint.contains(entry.key.toLowerCase())) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.config == null ? '添加API配置' : '编辑API配置'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '配置名称',
                  hintText: '例如: Kimi AI',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入配置名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: '输入API密钥',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入API Key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // API端点选择
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'API提供商',
                  border: OutlineInputBorder(),
                ),
                value: _getProviderFromEndpoint(_endpointController.text),
                items: _predefinedEndpoints.keys.map((provider) {
                  return DropdownMenuItem(
                    value: provider,
                    child: Text(provider),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _endpointController.text = _predefinedEndpoints[value]!;
                      // 重置模型为所选提供商的第一个模型
                      if (_predefinedModels.containsKey(value)) {
                        _modelController.text = _predefinedModels[value]![0];
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _endpointController,
                decoration: const InputDecoration(
                  labelText: 'API端点',
                  hintText: '例如: https://api.moonshot.cn/v1',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入API端点';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 模型选择
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '模型',
                  border: OutlineInputBorder(),
                ),
                value: _predefinedModels.values
                          .expand((models) => models)
                          .contains(_modelController.text)
                        ? _modelController.text
                        : null,
                items: [
                  // 根据当前端点获取相应的模型列表
                  for (final provider in _predefinedEndpoints.keys)
                    if (_endpointController.text == _predefinedEndpoints[provider] || 
                        _endpointController.text.contains(provider.toLowerCase()))
                      ..._predefinedModels[provider]!.map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _modelController.text = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              
              // 自定义模型
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: '自定义模型',
                  hintText: '如列表中没有您需要的模型，请在此输入',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入模型名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 温度设置
              Text(
                '温度: ${_temperature.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _temperature,
                min: 0.0,
                max: 2.0,
                divisions: 40,
                label: _temperature.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _temperature = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              
              // 设为默认
              CheckboxListTile(
                title: const Text('设为默认配置'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
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
        ElevatedButton(
          onPressed: _saveConfig,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _saveConfig() {
    if (_formKey.currentState?.validate() ?? false) {
      final config = APIConfig(
        id: widget.config?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        apiKey: _apiKeyController.text,
        apiEndpoint: _endpointController.text,
        model: _modelController.text,
        temperature: _temperature,
        isDefault: _isDefault,
      );
      widget.onSave(config);
      Navigator.pop(context);
    }
  }
}
