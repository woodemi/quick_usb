# quick_usb

A cross-platform (Android/Windows/macOS/Linux) USB plugin for Flutter

## Usage

- List device
- Check/Request permission
- Open/Close device
- Get/Set configuration

### List devices

```dart
await QuickUsb.init();
// ...
var deviceList = await QuickUsb.getDeviceList();
// ...
await QuickUsb.exit();
```

### Check/Request permission

_**Android Only**_

```dart
var hasPermission = await QuickUsb.hasPermission(device);
print('hasPermission $hasPermission');
// ...
await QuickUsb.requestPermission(device);
```

### Open/Close device

```dart
var openDevice = await QuickUsb.openDevice(device);
print('openDevice $openDevice');
// ...
await QuickUsb.closeDevice();
```

### Get/Set configuration

```dart
var configuration = await QuickUsb.getConfiguration(index);
print('getConfiguration $configuration');
// ...
var setConfiguration = await QuickUsb.setConfiguration(configuration);
print('setConfiguration $getConfiguration');
```

### Claim/Release interface

```dart
var claimInterface = await QuickUsb.claimInterface(interface);
print('claimInterface $claimInterface');
// ...
var releaseInterface = await QuickUsb.releaseInterface(interface);
print('releaseInterface $releaseInterface');
```

### Bulk transfer in/out

```dart
var bulkTransferIn = await QuickUsb.bulkTransferIn(endpoint, 1024);
print('bulkTransferIn ${hex.encode(bulkTransferIn)}');
// ...
var bulkTransferOut = await QuickUsb.bulkTransferOut(endpoint, data);
print('bulkTransferOut $bulkTransferOut');
```