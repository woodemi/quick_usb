import 'quick_usb_platform_interface.dart';

class QuickUsbWindows extends _QuickUsbDesktop {}

class QuickUsbMacos extends _QuickUsbDesktop {}

class QuickUsbLinux extends _QuickUsbDesktop {}

class _QuickUsbDesktop extends QuickUsbPlatform {
  @override
  Future<String> get platformVersion {
    // TODO: implement platformVersion
    throw UnimplementedError();
  }
}
