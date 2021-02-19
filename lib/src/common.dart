import 'package:flutter/foundation.dart';

class UsbDevice {
  final String identifier;
  final int vendorId;
  final int productId;
  final int configurationCount;

  UsbDevice({
    @required this.identifier,
    @required this.vendorId,
    @required this.productId,
    @required this.configurationCount,
  });

  factory UsbDevice.fromMap(Map<dynamic, dynamic> map) {
    return UsbDevice(
      identifier: map['identifier'],
      vendorId: map['vendorId'],
      productId: map['productId'],
      configurationCount: map['configurationCount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'vendorId': vendorId,
      'productId': productId,
      'configurationCount': configurationCount,
    };
  }

  @override
  String toString() => toMap().toString();
}

abstract class UsbConfiguration {
  final int id;
  final int index;
  final List<UsbInterface> interfaces;

  UsbConfiguration({
    @required this.id,
    @required this.index,
    @required this.interfaces,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'index': index,
      'interfaces': interfaces.map((e) => e.toMap()).toList(),
    };
  }

  @override
  String toString() => toMap().toString();

  Future<UsbInterface> getInterface(int index);
}

class UsbInterface {
  final int id;
  final int alternateSetting;

  UsbInterface({
    @required this.id,
    @required this.alternateSetting,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alternateSetting': alternateSetting,
    };
  }
}