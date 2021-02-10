import 'dart:ffi';

import 'package:libusb/libusb64.dart';

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
}
