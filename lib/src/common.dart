import 'package:flutter/foundation.dart';

class UsbDevice {
  final String identifier;
  final int vendorId;
  final int productId;

  UsbDevice({
    @required this.identifier,
    @required this.vendorId,
    @required this.productId,
  });

  factory UsbDevice.fromMap(Map<dynamic, dynamic> map) {
    return UsbDevice(
      identifier: map['identifier'],
      vendorId: map['vendorId'],
      productId: map['productId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'vendorId': vendorId,
      'productId': productId,
    };
  }

  @override
  String toString() => toMap().toString();
}
