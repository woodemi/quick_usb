import 'package:quick_usb/src/quick_usb_platform_interface.dart';

class QuickUsbLinux extends QuickUsbPlatform {
  @override
  Future<String> get platformVersion {
    return Future.value('Ubuntu 18.04 LTS');
  }
}
