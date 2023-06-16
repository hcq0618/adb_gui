import 'package:adb_gui/ui/base_stateful_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../commands/adb_packages.dart';
import '../widgets/command_value_field.dart';

class PackageCommandButtonGroup extends BaseStatefulWidget {
  const PackageCommandButtonGroup(super.adb, super.consoleController,
      {super.key});

  @override
  State<StatefulWidget> createState() => _PackageCommandButtonGroupState();
}

class _PackageCommandButtonGroupState
    extends BaseState<PackageCommandButtonGroup> {
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

  var _isKeepDataChecked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPackageCommandButtons(),
        _buildPackageCommandV2Buttons()
      ],
    );
  }

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
              child: CommandValueField(
                width: 100,
                hint: "filter name",
                buttonText: "List Packages",
                onPressed: (String text) {
                  consoleController.outputStreamConsole(
                      adb.listPackages(_listPackagesParameter, filter: text));
                },
              ),
            ),
            _buildInstallCommandButton(),
            _buildUninstallPackageButton(),
            buildDivider(),
            CommandValueField(
              width: 120,
              hint: "package name",
              buttonText: "Clear Data",
              onPressed: (String text) {
                consoleController.outputStreamConsole(adb.clearData(text));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInstallCommandButton() {
    return Row(
      children: [
        buildDivider(),
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
                    consoleController.outputStreamConsole(
                        adb.installPackage(_installPackageParameter, path));
                  }
                } else {
                  // User canceled the picker
                }
              }),
        )
      ],
    );
  }

  Widget _buildUninstallPackageButton() {
    return Row(
      children: [
        buildDivider(),
        CommandValueField(
          width: 120,
          hint: "package name",
          buttonText: "Uninstall an App",
          onPressed: (String text) {
            consoleController.outputStreamConsole(
                adb.uninstallPackage(text, keepData: _isKeepDataChecked));
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
            CommandValueField(
              width: 120,
              hint: "package name",
              buttonText: "Show App Details",
              onPressed: (String text) {
                consoleController
                    .outputStreamConsole(adb.showPackageDetails(text));
              },
            ),
            buildDivider(),
            CommandValueField(
              width: 120,
              hint: "package name",
              buttonText: "Show App Path",
              onPressed: (String text) {
                consoleController
                    .outputStreamConsole(adb.showPackagePath(text));
              },
            ),
            buildDivider(),
            CommandValueField(
              width: 120,
              hint: "package name",
              buttonText: "Force Stop App",
              onPressed: (String text) {
                consoleController.outputStreamConsole(adb.forceStopApp(text));
              },
            )
          ],
        ),
      ),
    );
  }
}
