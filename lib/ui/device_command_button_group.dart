import 'package:flutter/material.dart';
import '../widgets/command_value_field.dart';
import 'base_stateful_widget.dart';

class DeviceCommandButtonGroup extends BaseStatefulWidget {
  const DeviceCommandButtonGroup(super.adb, super.consoleController,
      {super.key});

  @override
  State<StatefulWidget> createState() => _DeviceCommandButtonGroupState();
}

class _DeviceCommandButtonGroupState
    extends BaseState<DeviceCommandButtonGroup> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            OutlinedButton(
                child: const Text("Screen Resolution"),
                onPressed: () {
                  consoleController
                      .outputStreamConsole(adb.getScreenResolution());
                }),
            buildDivider(),
            OutlinedButton(
                child: const Text("Screen Density"),
                onPressed: () {
                  consoleController.outputStreamConsole(adb.getScreenDensity());
                }),
            buildDivider(),
            OutlinedButton(
                child: const Text("Android Id"),
                onPressed: () {
                  consoleController.outputStreamConsole(adb.getAndroidId());
                }),
            buildDivider(),
            OutlinedButton(
                child: const Text("Android Version"),
                onPressed: () {
                  consoleController
                      .outputStreamConsole(adb.getAndroidVersion());
                }),
            buildDivider(),
            OutlinedButton(
                child: const Text("Ip Address"),
                onPressed: () {
                  consoleController.outputStreamConsole(adb.getIpAddress());
                }),
            buildDivider(),
            OutlinedButton(
                child: const Text("Memory Info"),
                onPressed: () {
                  consoleController.outputStreamConsole(adb.getMemoryInfo());
                }),
            buildDivider(),
            CommandValueField(
              width: 130,
              hint: "package name",
              buttonText: "Show UID",
              onPressed: (String text) {
                consoleController.outputStreamConsole(adb.showUID(text));
              },
            ),
          ],
        ),
      ),
    );
  }
}
