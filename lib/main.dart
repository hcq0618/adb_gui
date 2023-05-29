import 'package:adb_gui/commands/adb.dart';
import 'package:adb_gui/ui/console.dart';
import 'package:adb_gui/ui/refresh_button.dart';
import 'package:adb_gui/ui/value_command_field.dart';
import 'package:flutter/material.dart';

void main() async {
  final Adb adb = Adb();
  final devices = await adb.getOnlineDevices();

  // print(devices);
  runApp(AdbGUIApp(adb: adb, devices: devices));
}

class AdbGUIApp extends StatelessWidget {
  final Adb adb;
  final List<String> devices;

  const AdbGUIApp({super.key, required this.adb, required this.devices});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADB GUI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(adb, devices, title: 'ADB GUI'),
    );
  }
}

//ignore: must_be_immutable
class HomePage extends StatefulWidget {
  final String title;
  final Adb _adb;
  late List<DropdownMenuItem<String>> _deviceItems;

  HomePage(this._adb, List<String> devices, {super.key, required this.title}) {
    _buildDevicesMenu(devices);
  }

  _refreshDevices() async {
    final devices = await _adb.getOnlineDevices();
    _buildDevicesMenu(devices);
  }

  _buildDevicesMenu(List<String> devices) {
    _deviceItems = devices
        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
        .toList();
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ConsoleController _consoleController = ConsoleController();

  _updateSelectedDevice() {
    if (widget._adb.selectedDevice.isEmpty) {
      if (widget._deviceItems.isNotEmpty) {
        widget._adb.selectedDevice = widget._deviceItems[0].value ?? "";
      }
    } else {
      if (widget._deviceItems.isEmpty) {
        widget._adb.selectedDevice = "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateSelectedDevice();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                _buildDeviceSelector(),
                _buildServerButtons(),
              ],
            ),
          ),
          _buildConsole()
        ],
      ),
    );
  }

  Widget _buildConsole() {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Console(controller: _consoleController),
      ),
    );
  }

  Widget _buildDeviceSelector() {
    return Row(children: [
      DropdownButton<String>(
          value: widget._adb.selectedDevice,
          hint: const Text('Devices'),
          items: widget._deviceItems,
          onChanged: (String? device) {
            widget._adb.selectedDevice = device ?? "";
          }),
      RefreshButton(onPressed: () {
        setState(() {
          widget._refreshDevices();
        });
      }),
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: ElevatedButton.icon(
            icon: const Icon(Icons.clear),
            label: const Text("Clear Console"),
            onPressed: () {
              _consoleController.clearConsole();
            }),
      )
    ]);
  }

  Widget _buildServerButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(children: [
        OutlinedButton(
            child: const Text("Version"),
            onPressed: () async {
              final output = await widget._adb.getVersion();
              _consoleController.outputConsole(output);
            }),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ValueCommandField(
            hint: "Port",
            buttonText: "Start Adb",
            onPressed: (String text) async {
              final output = await widget._adb.startAdb(port: text);
              _consoleController.outputConsole(output);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: OutlinedButton(
              child: const Text("Stop Adb"),
              onPressed: () async {
                final output = await widget._adb.stopAdb();
                _consoleController.outputConsole(output);
              }),
        )
      ]),
    );
  }
}
