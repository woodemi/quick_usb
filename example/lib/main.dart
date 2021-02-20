import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:quick_usb/quick_usb.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _buildColumn(),
      ),
    );
  }

  Widget _buildColumn() {
    return Column(
      children: [
        _init_exit(),
        _getDeviceList(),
        _has_request(),
        _open_close(),
        _get_set_configuration(),
        _claim_release_interface(),
        _bulk_transfer(),
      ],
    );
  }

  Widget _init_exit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RaisedButton(
          child: Text('init'),
          onPressed: () async {
            var init = await QuickUsb.init();
            print('init $init');
          },
        ),
        RaisedButton(
          child: Text('exit'),
          onPressed: () async {
            await QuickUsb.exit();
            print('exit');
          },
        ),
      ],
    );
  }

  List<UsbDevice> _deviceList;

  Widget _getDeviceList() {
    return RaisedButton(
      child: Text('getDeviceList'),
      onPressed: () async {
        _deviceList = await QuickUsb.getDeviceList();
        print('deviceList $_deviceList');
      },
    );
  }

  Widget _has_request() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RaisedButton(
          child: Text('hasPermission'),
          onPressed: () async {
            var hasPermission = await QuickUsb.hasPermission(_deviceList.first);
            print('hasPermission $hasPermission');
          },
        ),
        RaisedButton(
          child: Text('requestPermission'),
          onPressed: () async {
            await QuickUsb.requestPermission(_deviceList.first);
            print('requestPermission');
          },
        ),
      ],
    );
  }

  Widget _open_close() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RaisedButton(
          child: Text('openDevice'),
          onPressed: () async {
            var openDevice = await QuickUsb.openDevice(_deviceList.first);
            print('openDevice $openDevice');
          },
        ),
        RaisedButton(
          child: Text('closeDevice'),
          onPressed: () async {
            await QuickUsb.closeDevice();
            print('closeDevice');
          },
        ),
      ],
    );
  }

  UsbConfiguration _configuration;

  Widget _get_set_configuration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RaisedButton(
          child: Text('getConfiguration'),
          onPressed: () async {
            _configuration = await QuickUsb.getConfiguration(0);
            print('getConfiguration $_configuration');
          },
        ),
        RaisedButton(
          child: Text('setConfiguration'),
          onPressed: () async {
            var getConfiguration =
            await QuickUsb.setConfiguration(_configuration);
            print('setConfiguration $getConfiguration');
          },
        ),
      ],
    );
  }

  Widget _claim_release_interface() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RaisedButton(
          child: Text('claimInterface'),
          onPressed: () async {
            var claimInterface =
            await QuickUsb.claimInterface(_configuration.interfaces[0]);
            print('claimInterface $claimInterface');
          },
        ),
        RaisedButton(
          child: Text('releaseInterface'),
          onPressed: () async {
            var releaseInterface =
                await QuickUsb.releaseInterface(_configuration.interfaces[0]);
            print('releaseInterface $releaseInterface');
          },
        ),
      ],
    );
  }

  Widget _bulk_transfer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RaisedButton(
          child: Text('bulkTransfer'),
          onPressed: () async {
            var data = Uint8List.fromList(utf8.encode(''));
            var bulkTransfer = await QuickUsb.bulkTransfer(data);
            print('bulkTransfer $bulkTransfer');
          },
        ),
      ],
    );
  }
}
