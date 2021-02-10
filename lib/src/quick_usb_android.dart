import 'dart:async';

import 'package:flutter/services.dart';
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
}
