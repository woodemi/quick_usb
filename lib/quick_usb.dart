import 'dart:io';

import 'package:quick_usb/src/quick_usb_android.dart';
import 'package:quick_usb/src/quick_usb_platform_interface.dart';
import 'package:quick_usb/src/quick_usb_windows.dart';

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
    }
    _manualDartRegistrationNeeded = false;
  }

  return QuickUsbPlatform.instance;
}

class QuickUsb {
  static Future<String> get platformVersion async {
    return _platform.platformVersion;
  }
}
