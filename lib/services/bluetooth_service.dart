import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  Future<List<ScanResult>> startScan() async {
    try {
      await requestPermissions();
      
      // 确保蓝牙已开启
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        throw Exception('请先开启蓝牙');
      }

      // 确保之前的扫描已停止
      if (await FlutterBluePlus.isScanning.first) {
        await FlutterBluePlus.stopScan();
      }

      // 使用同步方式扫描
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidUsesFineLocation: true,
      );
      
      // 等待扫描完成
      await Future.delayed(const Duration(seconds: 4));
      
      // 获取扫描结果
      final results = FlutterBluePlus.lastScanResults
          .where((result) => 
              result.device.name.isNotEmpty && 
              result.rssi > -90)
          .toList();
      
      return results;
    } catch (e) {
      await FlutterBluePlus.stopScan();
      throw Exception('扫描失败，请重试');
    }
  }

  Stream<BluetoothAdapterState> get state => FlutterBluePlus.adapterState;

  Future<bool> isBluetoothEnabled() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.location.request();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 5));
    } catch (e) {
      throw Exception('连接失败，请重试');
    }
  }

  Future<void> openBluetoothSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.generalSettings);
  }
}
