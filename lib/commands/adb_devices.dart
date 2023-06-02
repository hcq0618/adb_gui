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

  Stream<String> startAdb({String port = ''}) async* {
    if (port.isNotEmpty) {
      yield* command("adb -P $port start-server");
    } else {
      yield* command("adb start-server");
    }
  }

  Stream<String> stopAdb() async* {
    yield* command("adb kill-server");
  }

  Stream<String> getVersion() async* {
    yield* command("adb version");
  }

  Stream<String> pair(String target) async* {
    yield* command("adb pair $target");
  }

  Stream<String> connect(String target) async* {
    yield* command("adb connect $target");
  }

  Stream<String> disconnect(String target) async* {
    yield* command("adb disconnect $target");
  }

  Stream<String> tcpip(String port) async* {
    yield* command("adb tcpip $port");
  }
}
