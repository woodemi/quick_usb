import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;
import 'package:libusb/libusb64.dart';
import 'package:quick_usb/src/common.dart';

import 'quick_usb_platform_interface.dart';
import 'utils.dart';

late Libusb _libusb;

class QuickUsbWindows extends _QuickUsbDesktop {
  QuickUsbWindows() {
    _libusb = Libusb(DynamicLibrary.open('libusb-1.0.23.dll'));
  }
}

class QuickUsbMacos extends _QuickUsbDesktop {
  QuickUsbMacos() {
    _libusb = Libusb(DynamicLibrary.open('libusb-1.0.23.dylib'));
  }
}

class QuickUsbLinux extends _QuickUsbDesktop {
  QuickUsbLinux() {
    _libusb = Libusb(DynamicLibrary.open('${Platform.environment['EXE_DIR_PATH']}/lib/libusb-1.0.23.so'));
  }
}

class _QuickUsbDesktop extends QuickUsbPlatform {
  Pointer<libusb_device_handle>? _devHandle;

  @override
  Future<bool> init() async {
    return _libusb.libusb_init(nullptr) == libusb_error.LIBUSB_SUCCESS;
  }

  @override
  Future<void> exit() async {
    return _libusb.libusb_exit(nullptr);
  }

  @override
  Future<List<UsbDevice>> getDeviceList() {
    var deviceListPtr = ffi.calloc<Pointer<Pointer<libusb_device>>>();
    try {
      var count = _libusb.libusb_get_device_list(nullptr, deviceListPtr);
      if (count < 0) {
        return Future.value([]);
      }
      try {
        return Future.value(_iterateDevice(deviceListPtr.value).toList());
      } finally {
        _libusb.libusb_free_device_list(deviceListPtr.value, 1);
      }
    } finally {
      ffi.calloc.free(deviceListPtr);
    }
  }

  Iterable<UsbDevice> _iterateDevice(
      Pointer<Pointer<libusb_device>> deviceList) sync* {
    var descPtr = ffi.calloc<libusb_device_descriptor>();

    for (var i = 0; deviceList[i] != nullptr; i++) {
      var dev = deviceList[i];
      var addr = _libusb.libusb_get_device_address(dev);
      var getDesc = _libusb.libusb_get_device_descriptor(dev, descPtr) ==
          libusb_error.LIBUSB_SUCCESS;

      yield UsbDevice(
        identifier: addr.toString(),
        vendorId: getDesc ? descPtr.ref.idVendor : 0,
        productId: getDesc ? descPtr.ref.idProduct : 0,
        configurationCount: getDesc ? descPtr.ref.bNumConfigurations : 0,
      );
    }

    ffi.calloc.free(descPtr);
  }

  @override
  Future<bool> hasPermission(UsbDevice usbDevice) async {
    return true;
  }

  @override
  Future<void> requestPermission(UsbDevice usbDevice) async {
    return;
  }

  @override
  Future<bool> openDevice(UsbDevice usbDevice) async {
    assert(_devHandle == null, 'Last device not closed');

    var handle = _libusb.libusb_open_device_with_vid_pid(
        nullptr, usbDevice.vendorId, usbDevice.productId);
    if (handle == nullptr) {
      return false;
    }
    _devHandle = handle;
    return true;
  }

  @override
  Future<void> closeDevice() async {
    if (_devHandle != null) {
      _libusb.libusb_close(_devHandle!);
      _devHandle = null;
    }
  }

  @override
  Future<UsbConfiguration> getConfiguration(int index) async {
    assert(_devHandle != null, 'Device not open');

    var configDescPtrPtr = ffi.calloc<Pointer<libusb_config_descriptor>>();
    try {
      var device = _libusb.libusb_get_device(_devHandle!);
      var getConfigDesc =
          _libusb.libusb_get_config_descriptor(device, index, configDescPtrPtr);
      if (getConfigDesc != libusb_error.LIBUSB_SUCCESS) {
        throw 'getConfigDesc error: ${_libusb.describeError(getConfigDesc)}';
      }

      var configDescPtr = configDescPtrPtr.value;
      var usbConfiguration = UsbConfiguration(
        id: configDescPtr.ref.bConfigurationValue,
        index: configDescPtr.ref.iConfiguration,
        interfaces: _iterateInterface(
                configDescPtr.ref.interface_1, configDescPtr.ref.bNumInterfaces)
            .toList(),
      );
      _libusb.libusb_free_config_descriptor(configDescPtr);

      return usbConfiguration;
    } finally {
      ffi.calloc.free(configDescPtrPtr);
    }
  }

  Iterable<UsbInterface> _iterateInterface(
      Pointer<libusb_interface> interfacePtr, int interfaceCount) sync* {
    for (var i = 0; i < interfaceCount; i++) {
      var interface = interfacePtr[i];
      for (var j = 0; j < interface.num_altsetting; j++) {
        var intfDesc = interface.altsetting[j];
        yield UsbInterface(
          id: intfDesc.bInterfaceNumber,
          alternateSetting: intfDesc.bAlternateSetting,
          endpoints: _iterateEndpoint(intfDesc.endpoint, intfDesc.bNumEndpoints)
              .toList(),
        );
      }
    }
  }

  Iterable<UsbEndpoint> _iterateEndpoint(
      Pointer<libusb_endpoint_descriptor> endpointDescPtr,
      int endpointCount) sync* {
    for (var i = 0; i < endpointCount; i++) {
      var endpointDesc = endpointDescPtr[i];
      yield UsbEndpoint(
        endpointNumber: endpointDesc.bEndpointAddress & UsbEndpoint.MASK_NUMBER,
        direction: endpointDesc.bEndpointAddress & UsbEndpoint.MASK_DIRECTION,
      );
    }
  }

  @override
  Future<bool> setConfiguration(UsbConfiguration config) async {
    assert(_devHandle != null, 'Device not open');

    var setConfig = _libusb.libusb_set_configuration(_devHandle!, config.id);
    if (setConfig != libusb_error.LIBUSB_SUCCESS) {
      print('setConfig error: ${_libusb.describeError(setConfig)}');
      return false;
    }
    return true;
  }

  @override
  Future<bool> claimInterface(UsbInterface intf) async {
    assert(_devHandle != null, 'Device not open');

    var result = _libusb.libusb_claim_interface(_devHandle!, intf.id);
    return result == libusb_error.LIBUSB_SUCCESS;
  }

  @override
  Future<bool> releaseInterface(UsbInterface intf) async {
    assert(_devHandle != null, 'Device not open');

    var result = _libusb.libusb_release_interface(_devHandle!, intf.id);
    return result == libusb_error.LIBUSB_SUCCESS;
  }

  @override
  Future<Uint8List> bulkTransferIn(UsbEndpoint endpoint, int maxLength) async {
    assert(_devHandle != null, 'Device not open');
    assert(endpoint.direction == UsbEndpoint.DIRECTION_IN,
        'Endpoint\'s direction should be in');

    var actualLengthPtr = ffi.calloc<Int32>();
    var dataPtr = ffi.calloc<Uint8>(maxLength);
    try {
      var result = _libusb.libusb_bulk_transfer(
        _devHandle!,
        endpoint.endpointAddress,
        dataPtr,
        maxLength,
        actualLengthPtr,
        1000,
      );

      if (result != libusb_error.LIBUSB_SUCCESS) {
        throw 'bulkTransferIn error: ${_libusb.describeError(result)}';
      }
      return Uint8List.fromList(dataPtr.asTypedList(actualLengthPtr.value));
    } finally {
      ffi.calloc.free(actualLengthPtr);
      ffi.calloc.free(dataPtr);
    }
  }

  @override
  Future<int> bulkTransferOut(UsbEndpoint endpoint, Uint8List data) async {
    assert(_devHandle != null, 'Device not open');
    assert(endpoint.direction == UsbEndpoint.DIRECTION_OUT,
        'Endpoint\'s direction should be out');

    var actualLengthPtr = ffi.calloc<Int32>();
    var dataPtr = ffi.calloc<Uint8>(data.length);
    dataPtr.asTypedList(data.length).setAll(0, data);
    try {
      var result = _libusb.libusb_bulk_transfer(
        _devHandle!,
        endpoint.endpointAddress,
        dataPtr,
        data.length,
        actualLengthPtr,
        1000,
      );

      if (result != libusb_error.LIBUSB_SUCCESS) {
        print('bulkTransferOut error: ${_libusb.describeError(result)}');
        return -1;
      }
      return actualLengthPtr.value;
    } finally {
      ffi.calloc.free(actualLengthPtr);
      ffi.calloc.free(dataPtr);
    }
  }
}
