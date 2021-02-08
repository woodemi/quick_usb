import 'package:quick_usb/src/quick_usb_platform_interface.dart';

class QuickUsbWindows extends QuickUsbPlatform {
  @override
  Future<String> get platformVersion {
    return Future.value('Windows 10+');
  }
}
