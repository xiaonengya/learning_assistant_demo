import 'dart:io';

/// 头像仓库接口
abstract class AvatarRepository {
  /// 获取当前头像
  Future<File?> getAvatar();
  
  /// 保存新头像
  Future<void> saveAvatar(String sourcePath);
  
  /// 删除头像
  Future<void> deleteAvatar();
}
