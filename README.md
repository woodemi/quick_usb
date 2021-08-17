# quick_usb

A cross-platform (Android/Windows/macOS/Linux) USB plugin for Flutter

## Usage

- [List devices](#list-devices)
- [List devices with additional description](#list-devices-with-additional-description)
- [Get device description](#get-device-description)
- [Check/Request permission](#checkrequest-permission)
- [Open/Close device](#openclose-device)
- [Get/Set configuration](#getset-configuration)
- [Claim/Release interface](#claimrelease-interface)
- [Bulk transfer in/out](#bulk-transfer-inout)

### List devices

```dart
await QuickUsb.init();
// ...
var deviceList = await QuickUsb.getDeviceList();
// ...
await QuickUsb.exit();
```

### List devices with additional description

Returns devices list with manufacturer, product and serial number description.

Any of these attributes can be null.

On Android user will be asked for permission for each device if needed.

```dart
var descriptions = await QuickUsb.getDevicesWithDescription();
var deviceList = descriptions.map((e) => e.device).toList();
print('descriptions $descriptions');
```

### Get device description

Returns manufacturer, product and serial number description for specified device.

Any of these attributes can be null.

On Android user will be asked for permission if needed.

```dart
 var description = await QuickUsb.getDeviceDescription(device);
 print('description ${description.toMap()}');
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
