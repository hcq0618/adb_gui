import 'dart:ffi';
import 'dart:io';

import 'package:adb_gui/commands/adb_command.dart';
import 'package:dartx/dartx.dart';

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

class Intent {
  final Map<String, Object?> _kv = {};
  final Pair<String, String>? componentName;
  final String? action;
  final String? category;
  final String? component;

  Intent({this.action, this.category, this.component, this.componentName});

  Intent putExtra(String key, Object value) {
    _kv[key] = value;
    return this;
  }

  _appendParameter(
      StringBuffer sb, String parameterKey, Object parameterValue) {
    String prefix = "";
    if (sb.isNotEmpty) {
      prefix = " ";
    }
    sb.write("$prefix$parameterKey $parameterValue");
  }

  _appendOptionalParameter(
      StringBuffer sb, String parameterKey, String? parameterValue) {
    if (parameterValue.isNotNullOrEmpty) {
      _appendParameter(sb, parameterKey, parameterValue!);
    }
  }

  String toParameters() {
    final sb = StringBuffer();
    _appendOptionalParameter(sb, '-a', action);
    _appendOptionalParameter(sb, '-c', category);
    _appendOptionalParameter(sb, '-n', component);

    final componentName = this.componentName;
    if (componentName != null) {
      _appendParameter(
          sb, "--ecn ${componentName.first}", componentName.second);
    }

    _kv.forEach((key, value) {
      if (value == null) {
        _appendParameter(sb, "--esn $key", "");
      } else if (value is String) {
        _appendParameter(sb, "--es $key", value);
      } else if (value is bool) {
        _appendParameter(sb, "--ez $key", value);
      } else if (value is int) {
        _appendParameter(sb, "--ei $key", value);
      } else if (value is Long) {
        _appendParameter(sb, "--el $key", value);
      } else if (value is Float) {
        _appendParameter(sb, "--ef $key", value);
      } else if (value is Uri) {
        _appendParameter(sb, "--eu $key", value);
      } else if (value is List<Int>) {
        _appendParameter(sb, "--eia $key", value.join(','));
      } else if (value is List<Long>) {
        _appendParameter(sb, "--ela $key", value.join(','));
      }
    });
    return sb.toString();
  }
}
