import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(myApp());
}

class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Detector',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  @override

////////////////////////////////////////////////////////////////////////////////
  //used to store list of devices
  List<BluetoothDevice> _devicesList = [];

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    //getting list of devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }
    //random error about a tree or smth???
    if (!mounted) {
      return;
    }
    setState(() {
      _devicesList =
          devices; //store devices list in the devicesList for accessing outside of this class
    });
  }

  Future<void> enableBluetooth() async {
    //getting the current state of bluetooth
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    //if it is off turn it on, then retrieve devices
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
    } else {
      await getPairedDevices();
    }
  }

  //current bluetooth state is unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  //Get the instance of the current bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  var command;
  //Track the Bluetooth connection with the other device

////////////////////////////////////////////////////////////////////////////////
  BluetoothDevice HC05 =
      const BluetoothDevice(name: 'HC-05', address: '20:16:06:12:50:45');
//RUNS RIGHT WHEN WE START THE SHIT
  late BluetoothConnection connection;
  Future<void> _connect() async {
    await BluetoothConnection.toAddress(HC05.address).then((_connection) {
      connection = _connection;
    });
  }

  Future<void> listenMessage() async {
    try {
      command = connection.input.toString();
    } catch (e) {}
  }

  bool _isConnected = false;
  void initState() {
    super.initState();
    _connect();
    _isConnected = HC05.isConnected;
    listenMessage();
    if (command == "1") {
      selected = true;
    } else {
      selected = false;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  bool selected = true;
  Widget checkMark = const Icon(CupertinoIcons.check_mark_circled,
      color: Colors.black, size: 200);
  Widget wrongMark =
      const Icon(CupertinoIcons.xmark_circle, color: Colors.black, size: 200);
  ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Water Detector')),
        body: Center(
            child: Stack(children: <Widget>[
          AnimatedContainer(
              curve: Curves.fastOutSlowIn,
              duration: const Duration(seconds: 1),
              color: selected ? Colors.green : Colors.red,
              alignment: Alignment.center),
          Container(
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                  duration: const Duration(seconds: 2),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: selected ? checkMark : wrongMark)),
          Container(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                  style: style,
                  onPressed: () {
                    setState(() {
                      listenMessage();
                      if (command == "1") {
                        selected = true;
                      } else {
                        selected = false;
                      }
                    });
                  },
                  child: const Text('Refresh'))),
          Container(
              alignment: Alignment.topCenter,
              transform: Matrix4.translationValues(0.0, 50.0, 0),
              child: AnimatedOpacity(
                  duration: const Duration(seconds: 1),
                  opacity: selected ? 0.0 : 1.0,
                  child: const Text('There is No Water For The Dog!',
                      style: TextStyle(fontSize: 20))))
        ])));
  }
}
