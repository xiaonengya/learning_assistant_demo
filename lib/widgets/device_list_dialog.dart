import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:wifi_iot/wifi_iot.dart';

class BluetoothDeviceListDialog extends StatelessWidget {
  final List<ScanResult> devices;
  final Function(BluetoothDevice) onDeviceSelected;

  const BluetoothDeviceListDialog({
    super.key,
    required this.devices,
    required this.onDeviceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('可用设备'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index].device;
            return ListTile(
              title: Text(device.name),
              subtitle: Text('信号: ${devices[index].rssi} dBm'),
              onTap: () {
                onDeviceSelected(device);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}

class WiFiNetworkListDialog extends StatelessWidget {
  final List<WifiNetwork> networks;
  final Function(String, String) onNetworkSelected;

  const WiFiNetworkListDialog({
    super.key,
    required this.networks,
    required this.onNetworkSelected,
  });

  void _showPasswordDialog(BuildContext context, String ssid) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text('连接到 $ssid'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '密码',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context); // 关闭密码对话框
            Navigator.pop(context); // 关闭网络列表对话框
            onNetworkSelected(ssid, value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭密码对话框
              Navigator.pop(context); // 关闭网络列表对话框
              onNetworkSelected(ssid, controller.text);
            },
            child: const Text('连接'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('选择网络'),
      children: [
        if (networks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('没有找到网络'),
          )
        else
          ...networks.map((network) => SimpleDialogOption(
            onPressed: () => _showPasswordDialog(context, network.ssid ?? ''),
            child: ListTile(
              title: Text(network.ssid ?? '未知网络'),
              subtitle: Text('信号: ${network.level} dBm'),
              leading: Icon(
                Icons.wifi,
                color: (network.level ?? -100) > -67 ? Colors.green : Colors.orange,
              ),
            ),
          )),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
