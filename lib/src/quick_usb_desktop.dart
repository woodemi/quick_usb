import 'dart:ffi';

import 'package:ffi/ffi.dart' as ffi;
import 'package:libusb/libusb64.dart';
import 'package:quick_usb/src/common.dart';

import 'quick_usb_platform_interface.dart';
import 'utils.dart';

class QuickUsbWindows extends _QuickUsbDesktop {
  QuickUsbWindows() : super(DynamicLibrary.open('libusb-1.0.23.dll'));
}

class QuickUsbMacos extends _QuickUsbDesktop {
  QuickUsbMacos() : super(DynamicLibrary.open('libusb-1.0.23.dylib'));
}

class QuickUsbLinux extends _QuickUsbDesktop {
  QuickUsbLinux() : super(DynamicLibrary.open('libusb-1.0.23.so'));
}

class _QuickUsbDesktop extends QuickUsbPlatform {
  final Libusb _libusb;
  Pointer<libusb_device_handle> _devHandle;

  _QuickUsbDesktop(DynamicLibrary dynamicLibrary)
      : _libusb = Libusb(dynamicLibrary);

  @override
  Future<bool> init() async {
    return _libusb.libusb_init(nullptr) == libusb_error.LIBUSB_SUCCESS;
  }

  @override
  Future<void> exit() async {
    return _libusb.libusb_exit(nullptr);
  }

  @override
  Future<List<UsbDevice>> getDeviceList() {
    var deviceListPtr = ffi.allocate<Pointer<Pointer<libusb_device>>>();
    try {
      var count = _libusb.libusb_get_device_list(nullptr, deviceListPtr);
      if (count < 0) {
        return Future.value([]);
      }
      try {
        return Future.value(_iterateDevice(deviceListPtr.value).toList());
      } finally {
        _libusb.libusb_free_device_list(deviceListPtr.value, 1);
      }
    } finally {
      ffi.free(deviceListPtr);
    }
  }

  Iterable<UsbDevice> _iterateDevice(
      Pointer<Pointer<libusb_device>> deviceList) sync* {
    var descPtr = ffi.allocate<libusb_device_descriptor>();

    for (var i = 0; deviceList[i] != nullptr; i++) {
      var dev = deviceList[i];
      var addr = _libusb.libusb_get_device_address(dev);
      var getDesc = _libusb.libusb_get_device_descriptor(dev, descPtr) ==
          libusb_error.LIBUSB_SUCCESS;

      yield UsbDevice(
        identifier: addr.toString(),
        vendorId: getDesc ? descPtr.ref.idVendor : null,
        productId: getDesc ? descPtr.ref.idProduct : null,
        configurationCount: getDesc ? descPtr.ref.bNumConfigurations : null,
      );
    }

    ffi.free(descPtr);
  }

  @override
  Future<bool> hasPermission(UsbDevice usbDevice) async {
    return true;
  }

  @override
  Future<void> requestPermission(UsbDevice usbDevice) async {
    return;
  }

  @override
  Future<bool> openDevice(UsbDevice usbDevice) async {
    assert(_devHandle == null, 'Last device not closed');

    var handle = _libusb.libusb_open_device_with_vid_pid(
        nullptr, usbDevice.vendorId, usbDevice.productId);
    if (handle == nullptr) {
      return false;
    }
    _devHandle = handle;
    return true;
  }

  @override
  Future<void> closeDevice(UsbDevice usbDevice) async {
    if (_devHandle != null) {
      _libusb.libusb_close(_devHandle);
      _devHandle = null;
    }
  }

  @override
  Future<UsbConfiguration> getConfiguration(int index) async {
    assert(_devHandle != null, 'Device not open');

    var configDescPtrPtr = ffi.allocate<Pointer<libusb_config_descriptor>>();
    try {
      var device = _libusb.libusb_get_device(_devHandle);
      var getConfigDesc =
          _libusb.libusb_get_config_descriptor(device, index, configDescPtrPtr);
      if (getConfigDesc != libusb_error.LIBUSB_SUCCESS) {
        print('getConfigDesc error: ${_libusb.describeError(getConfigDesc)}');
        return null;
      }

      var configDescPtr = configDescPtrPtr.value;
      var usbConfiguration = UsbConfiguration(
        id: configDescPtr.ref.bConfigurationValue,
        index: configDescPtr.ref.iConfiguration,
        interfaceCount: configDescPtr.ref.bNumInterfaces,
      );
      _libusb.libusb_free_config_descriptor(configDescPtr);

      return usbConfiguration;
    } finally {
      ffi.free(configDescPtrPtr);
    }
  }

  @override
  Future<bool> setConfiguration(UsbConfiguration config) async {
    assert(_devHandle != null, 'Device not open');

    var setConfig = _libusb.libusb_set_configuration(_devHandle, config.id);
    if (setConfig != libusb_error.LIBUSB_SUCCESS) {
      print('setConfig error: ${_libusb.describeError(setConfig)}');
      return false;
    }
    return true;
  }
}
