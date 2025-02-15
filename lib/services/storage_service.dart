import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String avatarPathKey = 'avatar_path';
  static const String themeKey = 'app_theme';
  static const String configKey = 'api_configs';
  static const String presetKey = 'ai_presets';
  SharedPreferences? _prefs;
  bool get isInitialized => _prefs != null;

  Future<void> init() async {
    if (!isInitialized) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> saveAvatarPath(String path) async {
    if (!isInitialized) await init();
    if (_prefs == null) throw Exception('Storage not initialized');

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String savedPath = '${appDir.path}/$fileName';
    await File(path).copy(savedPath);

    await _prefs!.setString(avatarPathKey, savedPath);
  }

  String? getAvatarPath() {
    if (!isInitialized) return null;
    return _prefs?.getString(avatarPathKey);
  }

  Future<void> saveData(String key, List<Map<String, dynamic>> data) async {
    if (!isInitialized) await init();
    if (_prefs == null) throw Exception('Storage not initialized');

    await _prefs!.setString(key, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> loadData(String key) async {
    if (!isInitialized) await init();
    if (_prefs == null) throw Exception('Storage not initialized');

    final String? jsonStr = _prefs!.getString(key);
    if (jsonStr == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error decoding data: $e');
      return [];
    }
  }
}
