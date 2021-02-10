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
  String _platformVersion = 'Unknown';

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

  Widget _getDeviceList() {
    return RaisedButton(
      child: Text('getDeviceList'),
      onPressed: () async {
        var deviceList = await QuickUsb.getDeviceList();
        print('deviceList $deviceList');
      },
    );
  }
}
