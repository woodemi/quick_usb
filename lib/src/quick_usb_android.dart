import 'dart:async';

import 'package:flutter/services.dart';
import 'package:quick_usb/src/common.dart';
import 'package:quick_usb/src/quick_usb_platform_interface.dart';

class QuickUsbAndroid extends QuickUsbPlatform {
  static const MethodChannel _channel = const MethodChannel('quick_usb');

  @override
  Future<bool> init() async {
    return true;
  }

  @override
  Future<void> exit() async {
    return;
  }

  @override
  Future<List<UsbDevice>> getDeviceList() async {
    List<Map<dynamic, dynamic>> list =
        await _channel.invokeListMethod('getDeviceList');
    return list.map((e) => UsbDevice.fromMap(e)).toList();
  }

  @override
  Future<bool> hasPermission(UsbDevice usbDevice) {
    return _channel.invokeMethod('hasPermission', usbDevice.toMap());
  }

  @override
  Future<void> requestPermission(UsbDevice usbDevice) {
    return _channel.invokeMethod('requestPermission', usbDevice.toMap());
  }

  @override
  Future<bool> openDevice(UsbDevice usbDevice) {
    return _channel.invokeMethod('openDevice', usbDevice.toMap());
  }

  @override
  Future<void> closeDevice(UsbDevice usbDevice) {
    return _channel.invokeMethod('closeDevice', usbDevice.toMap());
  }
}
