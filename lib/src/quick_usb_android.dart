import 'dart:async';

import 'package:flutter/services.dart';
import 'package:quick_usb/src/common.dart';
import 'package:quick_usb/src/quick_usb_platform_interface.dart';

const MethodChannel _channel = const MethodChannel('quick_usb');

class QuickUsbAndroid extends QuickUsbPlatform {
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
  Future<void> closeDevice() {
    return _channel.invokeMethod('closeDevice');
  }

  @override
  Future<UsbConfiguration> getConfiguration(int index) async {
    var map = await _channel.invokeMethod('getConfiguration', {
      'index': index,
    });
    return UsbConfiguration.fromMap(map);
  }

  @override
  Future<bool> setConfiguration(UsbConfiguration config) {
    return _channel.invokeMethod('setConfiguration', config.toMap());
  }

  @override
  Future<bool> claimInterface(UsbInterface intf) {
    return _channel.invokeMethod('claimInterface', intf.toMap());
  }

  @override
  Future<bool> releaseInterface(UsbInterface intf) {
    return _channel.invokeMethod('releaseInterface', intf.toMap());
  }
}
