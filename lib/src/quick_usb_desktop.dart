import 'quick_usb_platform_interface.dart';

class QuickUsbWindows extends _QuickUsbDesktop {}

class QuickUsbMacos extends _QuickUsbDesktop {}

class QuickUsbLinux extends _QuickUsbDesktop {}

class _QuickUsbDesktop extends QuickUsbPlatform {
  @override
  Future<bool> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<void> exit() {
    // TODO: implement exit
    throw UnimplementedError();
  }
}
