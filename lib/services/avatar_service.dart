import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  late String _avatarPath;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      final appDir = await getApplicationDocumentsDirectory();
      _avatarPath = path.join(appDir.path, 'avatar.png');
      _initialized = true;
    }
  }

  Future<File?> getAvatar() async {
    await init();
    final file = File(_avatarPath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<void> saveAvatar(String sourcePath) async {
    await init();
    final file = File(sourcePath);
    if (await file.exists()) {
      final targetFile = File(_avatarPath);
      await targetFile.parent.create(recursive: true);
      await file.copy(_avatarPath);
    }
  }
}
