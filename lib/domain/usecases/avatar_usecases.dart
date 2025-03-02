import 'dart:io';
import '../repositories/avatar_repository.dart';

/// 获取头像
class GetAvatar {
  final AvatarRepository repository;

  GetAvatar(this.repository);

  Future<File?> call() async {
    return await repository.getAvatar();
  }
}

/// 保存头像
class SaveAvatar {
  final AvatarRepository repository;

  SaveAvatar(this.repository);

  Future<void> call(String sourcePath) async {
    await repository.saveAvatar(sourcePath);
  }
}

/// 删除头像
class DeleteAvatar {
  final AvatarRepository repository;

  DeleteAvatar(this.repository);

  Future<void> call() async {
    await repository.deleteAvatar();
  }
}
