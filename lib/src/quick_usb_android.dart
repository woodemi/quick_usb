import 'dart:async';
import 'dart:typed_data';

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
        (await _channel.invokeListMethod('getDeviceList'))!;
    return list.map((e) => UsbDevice.fromMap(e)).toList();
  }

  @override
  Future<bool> hasPermission(UsbDevice usbDevice) async {
    return await _channel.invokeMethod('hasPermission', usbDevice.toMap());
  }

  @override
  Future<void> requestPermission(UsbDevice usbDevice) {
    return _channel.invokeMethod('requestPermission', usbDevice.toMap());
  }

  @override
  Future<bool> openDevice(UsbDevice usbDevice) async {
    return await _channel.invokeMethod('openDevice', usbDevice.toMap());
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
  Future<bool> setConfiguration(UsbConfiguration config) async {
    return await _channel.invokeMethod('setConfiguration', config.toMap());
  }

  @override
  Future<bool> detachKernelDriver(UsbInterface intf) async {
    return true;
  }

  @override
  Future<bool> claimInterface(UsbInterface intf) async {
    return await _channel.invokeMethod('claimInterface', intf.toMap());
  }

  @override
  Future<bool> releaseInterface(UsbInterface intf) async {
    return await _channel.invokeMethod('releaseInterface', intf.toMap());
  }

  @override
  Future<Uint8List> bulkTransferIn(UsbEndpoint endpoint, int maxLength) async {
    assert(endpoint.direction == UsbEndpoint.DIRECTION_IN,
        'Endpoint\'s direction should be in');

    List<dynamic> data = await _channel.invokeMethod('bulkTransferIn', {
      'endpoint': endpoint.toMap(),
      'maxLength': maxLength,
    });
    return Uint8List.fromList(data.cast<int>());
  }

  @override
  Future<int> bulkTransferOut(UsbEndpoint endpoint, Uint8List data) async {
    assert(endpoint.direction == UsbEndpoint.DIRECTION_OUT,
        'Endpoint\'s direction should be out');

    return await _channel.invokeMethod('bulkTransferOut', {
      'endpoint': endpoint.toMap(),
      'data': data,
    });
  }

  @override
  Future<UsbDeviceDescription> getDeviceDescription(UsbDevice usbDevice) async {
    var result =
        await _channel.invokeMethod('getDeviceDescription', usbDevice.toMap());
    return UsbDeviceDescription(
      device: usbDevice,
      manufacturer: result['manufacturer'],
      product: result['product'],
      serialNumber: result['serialNumber'],
    );
  }

  @override
  Future<List<UsbDeviceDescription>> getDevicesWithDescription() async {
    var devices = await getDeviceList();
    var result = <UsbDeviceDescription>[];
    for (var device in devices) {
      result.add(await getDeviceDescription(device));
    }
    return result;
  }
}
