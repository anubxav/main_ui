import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late BluetoothDevice selectedDevice;
  late BluetoothCharacteristic selectedCharacteristic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('BLE Communication App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _startScanning();
              },
              child: Text('Start Scanning'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _stopScanning();
              },
              child: Text('Stop Scanning'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _connectToDevice();
              },
              child: Text('Connect to Device'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendData();
              },
              child: Text('Send Data'),
            ),
          ],
        ),
      ),
    );
  }

  void _startScanning() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        print('Device found: ${result.device.name}');
        print('Device ID: ${result.device.id}');
      }
    });
  }

  void _stopScanning() {
    flutterBlue.stopScan();
  }

  void _connectToDevice() async {
    try {
      List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
      if (devices.isNotEmpty) {
        selectedDevice = devices.first;
        print('Already connected to: ${selectedDevice.name}');
      } else {
        devices = (await flutterBlue
                .scan(timeout: const Duration(seconds: 4))
                .toList())
            .cast<BluetoothDevice>();
        if (devices.isNotEmpty) {
          selectedDevice = devices.first;
          await selectedDevice.connect();
          print('Connected to: ${selectedDevice.name}');
        } else {
          print('No devices found.');
        }
      }
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  void _sendData() async {
    if (selectedDevice != null) {
      List<BluetoothService> services = await selectedDevice.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          // Replace with the actual UUID of the characteristic you want to write to
          if (characteristic.uuid.toString() ==
              "0000ffe1-0000-1000-8000-00805f9b34fb") {
            selectedCharacteristic = characteristic;
            List<int> data = [0x01, 0x02, 0x03]; // Replace with your data
            await selectedCharacteristic.write(data);
            print('Data sent: $data');
          }
        }
      }
    } else {
      print('No device connected.');
    }
  }

  @override
  void dispose() {
    selectedDevice?.disconnect();
    super.dispose();
  }
}
