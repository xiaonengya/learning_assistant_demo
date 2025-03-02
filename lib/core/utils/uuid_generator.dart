/// 简单的UUID生成工具
class UuidGenerator {
  /// 生成一个简单的UUID
  static String generate() {
    return DateTime.now().microsecondsSinceEpoch.toString() + 
        '_' + 
        (1000 + (DateTime.now().millisecond * 1000).floor() % 9000).toString();
  }
  
  // 私有构造函数，防止实例化
  UuidGenerator._();
}
