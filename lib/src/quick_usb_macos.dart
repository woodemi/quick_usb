import 'package:quick_usb/src/quick_usb_platform_interface.dart';

class QuickUsbMacos extends QuickUsbPlatform {
  @override
  Future<String> get platformVersion {
    return Future.value('macOS 10.15.7');
  }
}
