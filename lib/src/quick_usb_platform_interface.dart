import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:quick_usb/src/common.dart';

abstract class QuickUsbPlatform extends PlatformInterface {
  QuickUsbPlatform() : super(token: _token);

  static final Object _token = Object();

  static late QuickUsbPlatform _instance;

  /// The default instance of [PathProviderPlatform] to use.
  ///
  /// Defaults to [MethodChannelPathProvider].
  static QuickUsbPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [PathProviderPlatform] when they register themselves.
  static set instance(QuickUsbPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> init({QuickUsbWindowConfig? window});

  Future<void> exit();

  Future<List<UsbDevice>> getDeviceList();

  Future<bool> hasPermission(UsbDevice usbDevice);

  Future<void> requestPermission(UsbDevice usbDevice);

  Future<bool> openDevice(UsbDevice usbDevice);

  Future<void> closeDevice();

  Future<UsbConfiguration> getConfiguration(int index);

  Future<bool> setConfiguration(UsbConfiguration config);

  Future<bool> claimInterface(UsbInterface intf);

  Future<bool> detachKernelDriver(UsbInterface intf);

  Future<bool> releaseInterface(UsbInterface intf);

  Future<Uint8List> bulkTransferIn(
      UsbEndpoint endpoint, int maxLength, int timeout);

  Future<int> bulkTransferOut(
      UsbEndpoint endpoint, Uint8List data, int timeout);

  Future<UsbDeviceDescription> getDeviceDescription(UsbDevice usbDevice);

  Future<List<UsbDeviceDescription>> getDevicesWithDescription();

  Future<void> setAutoDetachKernelDriver(bool enable);
}
