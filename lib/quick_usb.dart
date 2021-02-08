import 'dart:async';

import 'package:flutter/services.dart';

class QuickUsb {
  static const MethodChannel _channel = const MethodChannel('quick_usb');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
