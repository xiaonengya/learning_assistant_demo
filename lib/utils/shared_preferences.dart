import 'package:shared_preferences/shared_preferences.dart';

// 统一管理 SharedPreferences 实例
class PrefsUtil {
  static SharedPreferences? _prefs;
  
  static Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
