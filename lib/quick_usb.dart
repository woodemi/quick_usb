import 'dart:io';

import 'src/quick_usb_android.dart';
import 'src/quick_usb_desktop.dart';
import 'src/quick_usb_platform_interface.dart';

bool _manualDartRegistrationNeeded = true;

QuickUsbPlatform get _platform {
  // This is to manually endorse Dart implementations until automatic
  // registration of Dart plugins is implemented. For details see
  // https://github.com/flutter/flutter/issues/52267.
  if (_manualDartRegistrationNeeded) {
    // Only do the initial registration if it hasn't already been overridden
    // with a non-default instance.
    if (Platform.isAndroid) {
      QuickUsbPlatform.instance = QuickUsbAndroid();
    } else if (Platform.isWindows) {
      QuickUsbPlatform.instance = QuickUsbWindows();
    } else if (Platform.isMacOS) {
      QuickUsbPlatform.instance = QuickUsbMacos();
    } else if (Platform.isLinux) {
      QuickUsbPlatform.instance = QuickUsbLinux();
    }
    _manualDartRegistrationNeeded = false;
  }

  return QuickUsbPlatform.instance;
}

class QuickUsb {
  static Future<bool> init() => _platform.init();

  static Future<void> exit() => _platform.exit();
}
