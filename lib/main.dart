import 'dart:async';

import 'package:adb_gui/commands/adb.dart';
import 'package:adb_gui/commands/adb_packages.dart';
import 'package:adb_gui/widgets/console.dart';
import 'package:adb_gui/widgets/refresh_button.dart';
import 'package:adb_gui/widgets/value_command_field.dart';
import 'package:file_picker/file_picker.dart';
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
  final List<String> devices;

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
                _buildWirelessCommandButtons(),
                _buildPackageCommandButtons(),
                _buildPackageCommandV2Buttons(),
                _buildComponentCommandButtons()
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
            child: const Text("Version"),
            onPressed: () {
              _consoleController.outputStreamConsole(widget._adb.getVersion());
            }),
        _buildDivider(),
        ValueCommandField(
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
      ]),
    );
  }

  Widget _buildWirelessCommandButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: IntrinsicHeight(
        child: Row(children: [
          ValueCommandField(
            width: 160,
            hint: "ip address:[port]",
            buttonText: "Wireless Connect Device",
            onPressed: (String text) {
              _consoleController.outputStreamConsole(widget._adb.connect(text));
            },
          ),
          _buildDivider(),
          ValueCommandField(
            width: 100,
            hint: "ip address",
            buttonText: "Wireless Disconnect Device",
            onPressed: (String text) {
              _consoleController
                  .outputStreamConsole(widget._adb.disconnect(text));
            },
          ),
          _buildDivider(),
          ValueCommandField(
            width: 160,
            hint: "ip address:[port]",
            buttonText: "Wireless Pairing Device",
            onPressed: (String text) {
              _consoleController.outputStreamConsole(widget._adb.pair(text));
            },
          ),
          _buildDivider(),
          ValueCommandField(
            hint: "port",
            buttonText: "Listen TCP/IP Port",
            onPressed: (String text) {
              _consoleController.outputStreamConsole(widget._adb.tcpip(text));
            },
          ),
        ]),
      ),
    );
  }

  var _listPackagesParameter = ListPackagesParameter.all.value;
  final _listPackagesParameters = {
    ListPackagesParameter.all.value: 'All',
    ListPackagesParameter.withApk.value: 'With Apk',
    ListPackagesParameter.withInstaller.value: 'With Installer',
    ListPackagesParameter.onlyDisabled.value: 'Only Disabled',
    ListPackagesParameter.onlyEnabled.value: 'Only Enabled',
    ListPackagesParameter.onlySystem.value: 'Only System',
    ListPackagesParameter.only3rdParty.value: 'Only 3rd-Party',
    ListPackagesParameter.includeUninstalled.value: 'Include Uninstalled'
  };

  Widget _buildPackageCommandButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            DropdownButton<String>(
                value: _listPackagesParameter,
                hint: const Text('Parameters'),
                items: _listPackagesParameters.keys
                    .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(_listPackagesParameters[e] ?? "")))
                    .toList(),
                onChanged: (String? parameter) {
                  setState(() {
                    _listPackagesParameter =
                        parameter ?? ListPackagesParameter.all.value;
                  });
                }),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ValueCommandField(
                width: 100,
                hint: "filter name",
                buttonText: "List Packages",
                onPressed: (String text) {
                  _consoleController.outputStreamConsole(widget._adb
                      .listPackages(_listPackagesParameter, filter: text));
                },
              ),
            ),
            _buildInstallCommandButton(),
            _buildUninstallPackageButton(),
            _buildDivider(),
            ValueCommandField(
              width: 120,
              hint: "package name",
              buttonText: "Clear Data",
              onPressed: (String text) {
                _consoleController
                    .outputStreamConsole(widget._adb.clearData(text));
              },
            )
          ],
        ),
      ),
    );
  }

  var _installPackageParameter = InstallPackageParameter.normal.value;
  final _installPackageParameters = {
    InstallPackageParameter.normal.value: 'Normal',
    InstallPackageParameter.toProtectedDir.value: 'To Protected Directory',
    InstallPackageParameter.toSDCard.value: 'To SD Card',
    InstallPackageParameter.allowOverwrite.value: 'Allow Overwrite',
    InstallPackageParameter.allowTestOnly.value: 'Allow Test Only',
    InstallPackageParameter.allowDowngrade.value: 'Allow Downgrade',
    InstallPackageParameter.grantAllPermissions.value: 'Grant All Permissions',
    InstallPackageParameter.armeabiV7a.value: 'For armeabi-v7a Only',
    InstallPackageParameter.arm64V8a.value: 'For arm64-v8a Only',
    InstallPackageParameter.v86.value: 'For v86 Only',
    InstallPackageParameter.x86_64.value: 'For x86_64 Only'
  };

  Widget _buildInstallCommandButton() {
    return Row(
      children: [
        _buildDivider(),
        DropdownButton<String>(
            value: _installPackageParameter,
            hint: const Text('Parameters'),
            items: _installPackageParameters.keys
                .map((e) => DropdownMenuItem<String>(
                    value: e, child: Text(_installPackageParameters[e] ?? "")))
                .toList(),
            onChanged: (String? parameter) {
              setState(() {
                _installPackageParameter =
                    parameter ?? InstallPackageParameter.normal.value;
              });
            }),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: OutlinedButton(
              child: const Text("Install an Apk"),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['apk'],
                );
                if (result != null) {
                  final path = result.files.single.path;
                  if (path != null) {
                    _consoleController.outputStreamConsole(widget._adb
                        .installPackage(_installPackageParameter, path));
                  }
                } else {
                  // User canceled the picker
                }
              }),
        )
      ],
    );
  }

  var _isKeepDataChecked = false;

  Widget _buildUninstallPackageButton() {
    return Row(
      children: [
        _buildDivider(),
        ValueCommandField(
          width: 120,
          hint: "package name",
          buttonText: "Uninstall an App",
          onPressed: (String text) {
            _consoleController.outputStreamConsole(widget._adb
                .uninstallPackage(text, keepData: _isKeepDataChecked));
          },
        ),
        Checkbox(
          value: _isKeepDataChecked,
          onChanged: (bool? value) {
            setState(() {
              _isKeepDataChecked = value!;
            });
          },
        ),
        const Text("Keep Data")
      ],
    );
  }

  Widget _buildPackageCommandV2Buttons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            ValueCommandField(
              width: 120,
              hint: "package name",
              buttonText: "Show App Details",
              onPressed: (String text) {
                _consoleController
                    .outputStreamConsole(widget._adb.showPackageDetails(text));
              },
            ),
            _buildDivider(),
            ValueCommandField(
              width: 120,
              hint: "package name",
              buttonText: "Show App Path",
              onPressed: (String text) {
                _consoleController
                    .outputStreamConsole(widget._adb.showPackagePath(text));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCommandButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            OutlinedButton(
                child: const Text("Show Foreground Activity"),
                onPressed: () {
                  _consoleController.outputStreamConsole(
                      widget._adb.showForegroundActivity());
                }),
            _buildDivider(),
            ValueCommandField(
              width: 200,
              hint: "package name (optional)",
              buttonText: "Show Running Services",
              onPressed: (String text) {
                _consoleController.outputStreamConsole(
                    widget._adb.showRunningServices(packageName: text));
              },
            )
          ],
        ),
      ),
    );
  }
}
