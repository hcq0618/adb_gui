import 'package:process_run/shell.dart';

import 'adb_command.dart';

mixin AdbDevices on AdbCommand {
  Future<List<String>> getOnlineDevices() async {
    final output = await shell.run('adb devices');
    final result = <String>[];

    for (var element in output.outLines) {
      if (element.isEmpty) continue;
      if (element == 'List of devices attached') continue;
      if (element == 'no device' || element.contains('offline')) continue;

      final onlineIndex = element.indexOf('device');
      if (onlineIndex >= 0) {
        final serialNumber = element.substring(0, onlineIndex).trim();
        result.add(serialNumber);
      }
    }
    return result;
  }

  Future<String> startAdb({String? port}) async {
    if (port != null && port.isNotEmpty) {
      return command("adb -P $port start-server");
    } else {
      return command("adb start-server");
    }
  }

  Future<String> stopAdb() async {
    return command("adb kill-server");
  }

  Future<String> getVersion() async {
    return command("adb version");
  }
}
