import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';
import '../widgets/command_value_field.dart';
import 'base_stateless_widget.dart';

class WirelessCommandButtonGroup extends BaseStatelessWidget {
  const WirelessCommandButtonGroup(super.adb, super.consoleController,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: IntrinsicHeight(
        child: Row(children: [
          CommandValueField(
            width: 160,
            hint: "ip address:[port]",
            buttonText: "Wireless Connect Device",
            onPressed: (String text) {
              consoleController.outputStreamConsole(adb.connect(text));
            },
          ),
          buildDivider(),
          CommandValueField(
            width: 100,
            hint: "ip address",
            buttonText: "Wireless Disconnect Device",
            onPressed: (String text) {
              consoleController.outputStreamConsole(adb.disconnect(text));
            },
          ),
          buildDivider(),
          CommandValueField(
            width: 160,
            hint: "ip address:[port]",
            buttonText: "Wireless Pairing Device",
            onPressed: (String text) {
              consoleController.outputStreamConsole(adb.pair(text));
            },
          ),
          buildDivider(),
          CommandValueField(
            hint: "port",
            buttonText: "Listen TCP/IP Port",
            onPressed: (String text) {
              consoleController.outputStreamConsole(adb.tcpip(text));
            },
          ),
        ]),
      ),
    );
  }
}
