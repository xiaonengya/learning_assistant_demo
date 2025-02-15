import 'package:flutter/material.dart';
import '../../models/api_config.dart';

const Map<String, List<String>> predefinedModels = {
  'moonshot': ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'],
};

class APIConfigDialog extends StatefulWidget {
  final APIConfig? config;
  final Function(APIConfig) onSave;

  const APIConfigDialog({
    super.key,
    this.config,
    required this.onSave,
  });

  @override
  State<APIConfigDialog> createState() => _APIConfigDialogState();
}

class _APIConfigDialogState extends State<APIConfigDialog> {
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
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _endpointController.dispose();
    super.dispose();
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
              const SizedBox(height: 16),
              // ... API Key, Endpoint, Model Selection fields ...
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
        model: _selectedModel,
        isDefault: _isDefault,
      );
      widget.onSave(config);
      Navigator.pop(context);
    }
  }
}
