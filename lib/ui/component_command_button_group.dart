import 'package:adb_gui/ui/base_stateful_widget.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../commands/adb_components.dart';
import '../widgets/command_value_field.dart';

class ComponentCommandButtonGroup extends BaseStatefulWidget {
  const ComponentCommandButtonGroup(super.adb, super.consoleController,
      {super.key});

  @override
  State<StatefulWidget> createState() => _ComponentCommandButtonGroupState();
}

class _ComponentCommandButtonGroupState
    extends BaseState<ComponentCommandButtonGroup> {
  final _intentDataKeyController = TextEditingController();
  final _intentDataValueController = TextEditingController();

  final _servicePathController = TextEditingController();

  var _systemBroadcastAction = SystemBroadcast.notApplicable.action;
  final _customBroadcastActionController = TextEditingController();

  final _monkeyTestCountController = TextEditingController(text: "500");

  @override
  void dispose() {
    _intentDataKeyController.dispose();
    _intentDataValueController.dispose();
    _customBroadcastActionController.dispose();
    _monkeyTestCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildComponentCommandButtons(),
        _buildComponentCommandV2Buttons(),
        _buildComponentCommandV3Buttons()
      ],
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
                  consoleController
                      .outputStreamConsole(adb.showForegroundActivity());
                }),
            buildDivider(),
            CommandValueField(
              width: 200,
              hint: "package name (optional)",
              buttonText: "Show Running Services",
              onPressed: (String text) {
                consoleController.outputStreamConsole(
                    adb.showRunningServices(packageName: text));
              },
            ),
            buildDivider(),
            Container(
              width: 180,
              padding: const EdgeInsets.only(right: 10),
              child: TextField(
                controller: _intentDataKeyController,
                decoration:
                    const InputDecoration(hintText: "intent extra data key"),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _intentDataValueController,
                decoration:
                    const InputDecoration(hintText: "intent extra data value"),
              ),
            ),
            buildDivider(),
            CommandValueField(
              width: 270,
              hint: "<package name>/.<activity name>",
              buttonText: "Start Activity",
              onPressed: (String text) {
                consoleController.outputStreamConsole(adb
                    .startActivity(text, extraData: {
                  _intentDataKeyController.text: _intentDataValueController.text
                }));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCommandV2Buttons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            CommandValueField(
              width: 120,
              hint: "package name",
              buttonText: "Start Main Activity",
              onPressed: (String text) {
                consoleController.outputStreamConsole(adb
                    .startMainActivity(text, extraData: {
                  _intentDataKeyController.text: _intentDataValueController.text
                }));
              },
            ),
            buildDivider(),
            CommandValueField(
              controller: _servicePathController,
              width: 280,
              hint: "<package name>/.<service name>",
              buttonText: "Start Service",
              onPressed: (String text) {
                consoleController.outputStreamConsole(adb
                    .startService(text, extraData: {
                  _intentDataKeyController.text: _intentDataValueController.text
                }));
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: OutlinedButton(
                child: const Text("Stop Service"),
                onPressed: () {
                  consoleController.outputStreamConsole(
                      adb.stopService(_servicePathController.text));
                },
              ),
            ),
            buildDivider(),
            OutlinedButton(
              child: const Text("Start Navigator Bar"),
              onPressed: () {
                consoleController.outputStreamConsole(adb.startNavigatorBar());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCommandV3Buttons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            DropdownButton<String>(
              value: _systemBroadcastAction,
              hint: const Text('System Broadcast Action'),
              items: SystemBroadcast.values
                  .map((e) => DropdownMenuItem<String>(
                        value: e.action,
                        child: Text(e.name),
                      ))
                  .toList(),
              onChanged: (String? action) {
                setState(() {
                  _systemBroadcastAction =
                      action ?? SystemBroadcast.notApplicable.action;
                });
              },
            ),
            Container(
              width: 220,
              padding: const EdgeInsets.only(left: 10),
              child: TextField(
                controller: _customBroadcastActionController,
                decoration:
                    const InputDecoration(hintText: 'Custom Action (optional)'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CommandValueField(
                width: 370,
                hint: "<package name>/.<receiver name> (optional)",
                buttonText: "Send Broadcast",
                onPressed: (String text) {
                  consoleController.outputStreamConsole(adb.sendBroadcast(
                      _systemBroadcastAction.isNotEmpty
                          ? _systemBroadcastAction
                          : _customBroadcastActionController.text,
                      receiverPath: text));
                },
              ),
            ),
            buildDivider(),
            Container(
              width: 60,
              padding: const EdgeInsets.only(right: 10),
              child: TextField(
                controller: _monkeyTestCountController,
                decoration: const InputDecoration(hintText: "test count"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            CommandValueField(
              width: 130,
              hint: "package name",
              buttonText: "Monkey Test",
              onPressed: (String text) {
                consoleController.outputStreamConsole(adb.monkeyTest(
                    text, _monkeyTestCountController.text.toInt()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
