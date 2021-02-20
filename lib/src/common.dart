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

class UsbConfiguration {
  final int id;
  final int index;
  final List<UsbInterface> interfaces;

  UsbConfiguration({
    @required this.id,
    @required this.index,
    @required this.interfaces,
  });

  factory UsbConfiguration.fromMap(Map<dynamic, dynamic> map) {
    var interfaces = (map['interfaces'] as List)
        .map((e) => UsbInterface.fromMap(e))
        .toList();
    return UsbConfiguration(
      id: map['id'],
      index: map['index'],
      interfaces: interfaces,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'index': index,
      'interfaces': interfaces.map((e) => e.toMap()).toList(),
    };
  }

  @override
  String toString() => toMap().toString();
}

class UsbInterface {
  final int id;
  final int alternateSetting;
  final List<UsbEndpoint> endpoints;

  UsbInterface({
    @required this.id,
    @required this.alternateSetting,
    @required this.endpoints,
  });

  factory UsbInterface.fromMap(Map<dynamic, dynamic> map) {
    var endpoints =
        (map['endpoints'] as List).map((e) => UsbEndpoint.fromMap(e)).toList();
    return UsbInterface(
      id: map['id'],
      alternateSetting: map['alternateSetting'],
      endpoints: endpoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alternateSetting': alternateSetting,
      'endpoints': endpoints.map((e) => e.toMap()).toList(),
    };
  }

  @override
  String toString() => toMap().toString();
}

class UsbEndpoint {
  final int endpointNumber;
  final int direction;

  UsbEndpoint({
    @required this.endpointNumber,
    @required this.direction,
  });

  factory UsbEndpoint.fromMap(Map<dynamic, dynamic> map) {
    return UsbEndpoint(
      endpointNumber: map['endpointNumber'],
      direction: map['direction'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'endpointNumber': endpointNumber,
      'direction': direction,
    };
  }

  @override
  String toString() => toMap().toString();
}