import 'dart:io';
import 'package:path/path.dart' as path;
import '../../domain/repositories/avatar_repository.dart';

/// 头像仓库实现
class AvatarRepositoryImpl implements AvatarRepository {
  final Directory _appDirectory;
  final String _avatarFileName = 'user_avatar.png';

  AvatarRepositoryImpl(this._appDirectory);

  @override
  Future<File?> getAvatar() async {
    final avatarPath = path.join(_appDirectory.path, _avatarFileName);
    final avatarFile = File(avatarPath);
    
    if (await avatarFile.exists()) {
      return avatarFile;
    }
    
    return null;
  }

  @override
  Future<void> saveAvatar(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('源文件不存在', sourcePath);
    }

    final avatarPath = path.join(_appDirectory.path, _avatarFileName);

    // 复制源文件到目标路径
    await sourceFile.copy(avatarPath);
  }

  @override
  Future<void> deleteAvatar() async {
    final avatarPath = path.join(_appDirectory.path, _avatarFileName);
    final avatarFile = File(avatarPath);
    
    if (await avatarFile.exists()) {
      await avatarFile.delete();
    }
  }
}
