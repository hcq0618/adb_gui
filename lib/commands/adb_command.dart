import 'package:flutter/cupertino.dart';
import 'package:process_run/process_run.dart';

class AdbCommand {
  @protected
  final Shell shell = Shell();
  var selectedDevice = "";

  String selectedDeviceParameter() {
    if (selectedDevice.isEmpty) {
      return "";
    } else {
      return deviceParameter(selectedDevice);
    }
  }

  String deviceParameter(String serialNumber) {
    return "-s $serialNumber";
  }

  Future<String> commandFuture(String command) async {
    return await commandFutureFromStream(
        this.command(command, outputCommand: false));
  }

  Future<String> commandFutureFromStream(Stream<String> command) async {
    return await command.firstWhere((element) => true, orElse: () => "");
  }

  Stream<String> command(String command, {bool outputCommand = true}) async* {
    try {
      if (outputCommand) {
        yield "\$$command";
      }
      final output = await shell.run(command);
      final String outputText;

      if (output.errText.isNotEmpty) {
        outputText = output.errText;
      } else {
        outputText = output.outText;
      }

      yield outputText;
    } catch (e) {
      yield e.toString();
    }
  }
}
