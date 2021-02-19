import 'dart:ffi';

import 'package:ffi/ffi.dart' as ffi;
import 'package:libusb/libusb64.dart';
import 'package:quick_usb/src/common.dart';

import 'quick_usb_platform_interface.dart';

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
      var vendorId;
      var productId;
      var result = _libusb.libusb_get_device_descriptor(dev, descPtr);

      if (result == libusb_error.LIBUSB_SUCCESS) {
        vendorId = descPtr.ref.idVendor;
        productId = descPtr.ref.idProduct;
      }
      yield UsbDevice(
        identifier: addr.toString(),
        vendorId: vendorId,
        productId: productId,
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
    assert(_devHandle != null, 'Last device not opened');

    _libusb.libusb_close(_devHandle);
  }
}
