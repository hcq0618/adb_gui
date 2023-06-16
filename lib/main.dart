import 'package:adb_gui/commands/adb.dart';
import 'package:adb_gui/commands/adb_devices.dart';
import 'package:adb_gui/ui/component_command_button_group.dart';
import 'package:adb_gui/ui/device_command_button_group.dart';
import 'package:adb_gui/ui/package_command_button_group.dart';
import 'package:adb_gui/ui/wireless_command_button_group.dart';
import 'package:adb_gui/widgets/console.dart';
import 'package:adb_gui/widgets/refresh_button.dart';
import 'package:adb_gui/widgets/command_value_field.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1550, 1000),
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final adb = Adb();
  final devices = await adb.getOnlineDevices();

  // print(devices);
  runApp(AdbGUIApp(adb: adb, devices: devices));
}

class AdbGUIApp extends StatelessWidget {
  final Adb adb;
  final List<DeviceInfo> devices;

  const AdbGUIApp({super.key, required this.adb, required this.devices});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADB GUI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            background: const Color.fromARGB(255, 204, 232, 207),
            seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(adb, devices, title: 'ADB GUI'),
    );
  }
}

//ignore: must_be_immutable
class HomePage extends StatefulWidget {
  final String title;
  final Adb _adb;
  late List<DropdownMenuItem<String>> _deviceItems;

  HomePage(this._adb, List<DeviceInfo> devices,
      {super.key, required this.title}) {
    _buildDevicesMenu(devices);
  }

  _refreshDevices() async {
    final devices = await _adb.getOnlineDevices();
    _buildDevicesMenu(devices);
  }

  _buildDevicesMenu(List<DeviceInfo> devices) {
    _deviceItems = devices
        .map((e) => DropdownMenuItem<String>(
            value: e.serialNumber, child: Text(e.name)))
        .toList();
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _consoleController = ConsoleController();

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
                DeviceCommandButtonGroup(widget._adb, _consoleController),
                WirelessCommandButtonGroup(widget._adb, _consoleController),
                PackageCommandButtonGroup(widget._adb, _consoleController),
                ComponentCommandButtonGroup(widget._adb, _consoleController)
              ],
            ),
          ),
          _buildConsole()
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const VerticalDivider(
      width: 30,
      thickness: 1,
      indent: 10,
      endIndent: 10,
      color: Colors.grey,
    );
  }

  Widget _buildConsole() {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Console(_consoleController),
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
            setState(() {
              widget._adb.selectedDevice = device ?? "";
            });
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
      ),
      _buildDeviceCommandButtons(),
    ]);
  }

  Widget _buildDeviceCommandButtons() {
    return IntrinsicHeight(
      child: Row(children: [
        _buildDivider(),
        OutlinedButton(
            child: const Text("Adb Version"),
            onPressed: () {
              _consoleController
                  .outputStreamConsole(widget._adb.getAdbVersion());
            }),
        _buildDivider(),
        CommandValueField(
          hint: "port",
          buttonText: "Start Adb",
          onPressed: (String text) {
            _consoleController
                .outputStreamConsole(widget._adb.startAdb(port: text));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: OutlinedButton(
              child: const Text("Stop Adb"),
              onPressed: () {
                _consoleController.outputStreamConsole(widget._adb.stopAdb());
              }),
        ),
        _buildDivider(),
        CommandValueField(
          hint: "key code",
          buttonText: "Mock Key Event",
          helpUrl:
              "https://developer.android.com/reference/android/view/KeyEvent.html",
          onPressed: (String text) {
            _consoleController
                .outputStreamConsole(widget._adb.mockKeyEvent(text));
          },
        ),
      ]),
    );
  }
}
