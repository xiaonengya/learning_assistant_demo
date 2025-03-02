import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/avatar/avatar_bloc.dart';

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({super.key});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<AvatarBloc>().add(LoadAvatarEvent());
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        if (context.mounted) {
          context.read<AvatarBloc>().add(UpdateAvatarEvent(pickedFile.path));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动条
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // 标题
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '选择头像',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('拍照'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('从相册选择'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          
          BlocBuilder<AvatarBloc, AvatarState>(
            builder: (context, state) {
              if (state is AvatarLoaded && state.avatar != null) {
                return ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('删除当前头像', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AvatarBloc>().add(DeleteAvatarEvent());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          BlocBuilder<AvatarBloc, AvatarState>(
            builder: (context, state) {
              Widget avatarWidget;
              
              if (state is AvatarLoading) {
                avatarWidget = const CircularProgressIndicator();
              } else if (state is AvatarLoaded) {
                avatarWidget = GestureDetector(
                  onTap: _showPickerOptions,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    backgroundImage: state.avatar != null ? FileImage(state.avatar!) : null,
                    child: Stack(
                      children: [
                        if (state.avatar == null)
                          Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                avatarWidget = GestureDetector(
                  onTap: _showPickerOptions,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 40),
                  ),
                );
              }
              
              return avatarWidget;
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '个人头像',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                const Text('设置您的个人头像，让AI更了解您'),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('修改头像'),
                  onPressed: _showPickerOptions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
