import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class WiFiService {
  Future<bool> isWifiEnabled() async {
    return await WiFiForIoTPlugin.isEnabled();
  }

  Future<void> requestPermissions() async {
    await Permission.location.request();
    await Permission.nearbyWifiDevices.request();
  }

  Future<void> openWiFiSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.wifi);
  }

  Future<List<WifiNetwork>?> scanNetworks() async {
    try {
      await requestPermissions();
      if (!await isWifiEnabled()) {
        throw Exception('WiFi未启用');
      }
      
      // 等待WiFi初始化
      await Future.delayed(const Duration(seconds: 1));
      final networks = await WiFiForIoTPlugin.loadWifiList();
      return networks.where((network) => network.ssid?.isNotEmpty ?? false).toList();
    } catch (e) {
      throw Exception('扫描WiFi失败: $e');
    }
  }

  Future<bool> connectToNetwork(String ssid, String password) async {
    try {
      final result = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        security: NetworkSecurity.WPA,
        joinOnce: true,
      );
      return result;
    } catch (e) {
      throw Exception('连接失败: $e');
    }
  }

  Future<String?> getCurrentWifiName() async {
    try {
      return await WiFiForIoTPlugin.getSSID();
    } catch (e) {
      return null;
    }
  }
}
