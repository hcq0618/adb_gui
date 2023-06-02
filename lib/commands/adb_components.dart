import 'dart:io';

import 'package:adb_gui/commands/adb_command.dart';

mixin AdbComponents on AdbCommand {
  Stream<String> showForegroundActivity() async* {
    if (Platform.isWindows) {
      yield* command(
          "adb ${selectedDeviceParameter()} shell dumpsys activity activities | findstr mResumedActivity");
    } else {
      yield* command(
          "adb ${selectedDeviceParameter()} shell dumpsys activity activities | grep mFocused");
    }
  }

  Stream<String> showRunningServices({String packageName = ""}) async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell dumpsys activity services $packageName");
  }
}
