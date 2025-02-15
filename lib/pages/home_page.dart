import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  late String _timeString;
  String _currentWifi = '获取中...';
  String _currentBluetooth = '获取中...';
  final List<String> _welcomeMessages = [
    '欢迎回来！',
    '准备好开始学习了吗？',
    '今天也要加油哦！',
    '让我们开始美好的一天吧！'
  ];

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    _getCurrentConnections();
  }

  Future<void> _getCurrentConnections() async {
    try {
      // 获取当前WiFi名称
      final info = NetworkInfo();
      final wifiName = await info.getWifiName() ?? '未连接';
      
      // 获取当前蓝牙设备
      String bluetoothName = '未连接';
      if (await FlutterBluePlus.isOn) {
        final connectedDevices = await FlutterBluePlus.connectedDevices;
        if (connectedDevices.isNotEmpty) {
          bluetoothName = connectedDevices.first.name;
        }
      }

      if (mounted) {
        setState(() {
          _currentWifi = wifiName.replaceAll('"', '');
          _currentBluetooth = bluetoothName;
        });
      }
    } catch (e) {
      print('获取连接信息失败: $e');
    }
  }

  void _getTime() {
    setState(() {
      _timeString = _formatDateTime(DateTime.now());
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:' 
           '${dateTime.minute.toString().padLeft(2, '0')}:' 
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _timeString,
            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            _welcomeMessages[DateTime.now().second % _welcomeMessages.length],
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => AppSettings.openAppSettings(
                  type: AppSettingsType.bluetooth,
                ),
                icon: const Icon(Icons.bluetooth),
                label: Text(_currentBluetooth == '未连接' 
                    ? '蓝牙'
                    : '蓝牙: $_currentBluetooth'
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => AppSettings.openAppSettings(
                  type: AppSettingsType.wifi,
                ),
                icon: const Icon(Icons.wifi),
                label: Text(_currentWifi == '未连接' 
                    ? 'WiFi'
                    : 'WiFi: $_currentWifi'
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
