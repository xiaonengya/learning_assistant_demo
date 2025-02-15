import 'package:flutter/services.dart';

class SystemService {
  static final SystemService _instance = SystemService._internal();
  factory SystemService() => _instance;
  SystemService._internal();

  static const platform = MethodChannel('com.example.app/system');

  Future<void> openBluetoothSettings() async {
    await platform.invokeMethod('openBluetoothSettings');
  }

  Future<void> openWifiSettings() async {
    await platform.invokeMethod('openWifiSettings');
  }

  // ...other existing system management methods...
}
