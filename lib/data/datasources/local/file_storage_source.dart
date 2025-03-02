import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 文件存储数据源
class FileStorageSource {
  late final Directory _directory;
  
  /// 创建一个文件存储实例
  static Future<FileStorageSource> create() async {
    final instance = FileStorageSource._();
    await instance._init();
    return instance;
  }
  
  FileStorageSource._();
  
  Future<void> _init() async {
    _directory = await getApplicationDocumentsDirectory();
  }
  
  /// 获取应用文档目录
  Directory get directory => _directory;
  
  /// 在应用文档目录下创建子目录
  Future<Directory> getOrCreateSubDirectory(String name) async {
    final subDir = Directory('${_directory.path}/$name');
    
    if (!await subDir.exists()) {
      await subDir.create(recursive: true);
    }
    
    return subDir;
  }
  
  /// 保存文件
  Future<File> saveFile(String fileName, List<int> bytes, {String? subDir}) async {
    final Directory targetDir;
    
    if (subDir != null) {
      targetDir = await getOrCreateSubDirectory(subDir);
    } else {
      targetDir = _directory;
    }
    
    final filePath = '${targetDir.path}/$fileName';
    final file = File(filePath);
    return await file.writeAsBytes(bytes);
  }
  
  /// 读取文件
  Future<List<int>> readFile(String fileName, {String? subDir}) async {
    final Directory targetDir;
    
    if (subDir != null) {
      targetDir = await getOrCreateSubDirectory(subDir);
    } else {
      targetDir = _directory;
    }
    
    final filePath = '${targetDir.path}/$fileName';
    final file = File(filePath);
    
    if (!await file.exists()) {
      throw FileSystemException('文件不存在', filePath);
    }
    
    return await file.readAsBytes();
  }
  
  /// 删除文件
  Future<void> deleteFile(String fileName, {String? subDir}) async {
    final Directory targetDir;
    
    if (subDir != null) {
      targetDir = await getOrCreateSubDirectory(subDir);
    } else {
      targetDir = _directory;
    }
    
    final filePath = '${targetDir.path}/$fileName';
    final file = File(filePath);
    
    if (await file.exists()) {
      await file.delete();
    }
  }
}
