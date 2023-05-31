import 'package:process_run/process_run.dart';

class AdbCommand {
  final Shell shell = Shell();
  String selectedDevice = "";

  String selectedDeviceParameter() {
    if (selectedDevice.isEmpty) {
      return "";
    } else {
      return "-s $selectedDevice";
    }
  }

  Future<String> command(String command) async {
    try {
      final output = await shell.run(command);
      final String outputText;

      if (output.errText.isNotEmpty) {
        outputText = output.errText;
      } else {
        outputText = output.outText;
      }

      return "\$$command\n$outputText";
    } catch (e) {
      return "\$$command\n$e";
    }
  }
}
