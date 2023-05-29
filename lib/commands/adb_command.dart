import 'package:process_run/process_run.dart';

class AdbCommand {
  final Shell shell = Shell();
  String selectedDevice = "";

  String _selectedDeviceParameter() {
    if (selectedDevice.isEmpty) {
      return "";
    } else {
      return "-s $selectedDevice";
    }
  }

  Future<String> command(String command) async {
    final output = await shell.run(command);
    return "\$$command\n${output.outText}";
  }
}
