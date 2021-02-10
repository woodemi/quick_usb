# quick_usb

A cross-platform (Android/Windows/macOS/Linux) USB plugin for Flutter

## Usage

- List device

### List devices

```dart
await QuickUsb.init();
// ...
var deviceList = await QuickUsb.getDeviceList();
// ...
await QuickUsb.exit();
```

