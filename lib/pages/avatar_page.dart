import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/avatar_service.dart';
import '../services/avatar_state_service.dart';

class AvatarUpdateNotification extends Notification {
  final File avatar;
  AvatarUpdateNotification(this.avatar);
}

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final AvatarService _avatarService = AvatarService();
  final _avatarStateService = AvatarStateService();

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar();
  }

  Future<void> _loadSavedAvatar() async {
    await _avatarService.init();
    final savedAvatar = await _avatarService.getAvatar();
    if (savedAvatar != null) {
      setState(() => _image = savedAvatar);
    }
  }

  Future<void> _getImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final newAvatar = File(pickedFile.path);
        
        // 先保存到本地
        await _avatarService.saveAvatar(pickedFile.path);
        
        // 更新UI和全局状态
        setState(() => _image = newAvatar);
        _avatarStateService.updateAvatar(newAvatar);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('头像已更新')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新头像失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 120,  // 增加半径
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null ? const Icon(Icons.person, size: 100) : null,  // 增加图标大小
          ),
          const SizedBox(height: 30),  // 增加间距
          ElevatedButton.icon(
            onPressed: _getImage,
            icon: const Icon(Icons.add_photo_alternate, size: 24),  // 增加按钮图标大小
            label: const Text('选择头像', style: TextStyle(fontSize: 16)),  // 增加文字大小
          ),
        ],
      ),
    );
  }
}
