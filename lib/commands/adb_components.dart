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

  Stream<String> startActivity(String activityPath,
      {Map<String, String>? extraData}) async* {
    yield* command(
        "adb shell am start ${Intent(component: activityPath).putMap(extraData).toParameters()}");
  }

  Stream<String> startMainActivity(String packageName,
      {Map<String, String>? extraData}) async* {
    yield* command(
        "adb shell monkey ${Intent(packageName: packageName, category: 'android.intent.category.LAUNCHER 1').putMap(extraData).toParameters()}");
  }

  Stream<String> startService(String servicePath,
      {Map<String, String>? extraData}) async* {
    yield* command(
        "adb shell am startservice ${Intent(component: servicePath).putMap(extraData).toParameters()}");
  }

  Stream<String> stopService(String servicePath) async* {
    yield* command(
        "adb shell am stopservice ${Intent(component: servicePath).toParameters()}");
  }

  Stream<String> startNavigatorBar() async* {
    yield* startService("com.android.systemui/.SystemUIService");
  }

  Stream<String> sendBroadcast(String action, {String? receiverPath}) async* {
    yield* command(
        "adb shell am broadcast ${Intent(action: action, component: receiverPath).toParameters()}");
  }
}

enum SystemBroadcast {
  notApplicable(""),
  connectivityChange("android.net.conn.CONNECTIVITY_CHANGE"),
  screenOn("android.intent.action.SCREEN_ON"),
  screenOff("android.intent.action.SCREEN_OFF"),
  batteryLow("android.intent.action.BATTERY_LOW"),
  batteryOkay("android.intent.action.BATTERY_OKAY"),
  bootCompleted("android.intent.action.BOOT_COMPLETED"),
  deviceStorageLow("android.intent.action.DEVICE_STORAGE_LOW"),
  deviceStorageOk("android.intent.action.DEVICE_STORAGE_OK"),
  packageAdded("android.intent.action.PACKAGE_ADDED"),
  stateChange("android.net.wifi.STATE_CHANGE"),
  wifiStateChanged("android.net.wifi.WIFI_STATE_CHANGED"),
  batteryChanged("android.intent.action.BATTERY_CHANGED"),
  inputMethodChanged("android.intent.action.INPUT_METHOD_CHANGED"),
  actionPowerConnected("android.intent.action.ACTION_POWER_CONNECTED"),
  actionPowerDisconnected("android.intent.action.ACTION_POWER_DISCONNECTED"),
  dreamingStarted("android.intent.action.DREAMING_STARTED"),
  dreamingStopped("android.intent.action.DREAMING_STOPPED"),
  wallpaperChanged("android.intent.action.WALLPAPER_CHANGED"),
  headsetPlug("android.intent.action.HEADSET_PLUG"),
  mediaUnmounted("android.intent.action.MEDIA_UNMOUNTED"),
  mediaMounted("android.intent.action.MEDIA_MOUNTED"),
  powerSaveModeChanged("android.os.action.POWER_SAVE_MODE_CHANGED");

  const SystemBroadcast(this.action);

  final String action;
}

class Intent {
  final Map<String, Object?> _kv = {};
  final String? packageName;
  final Pair<String, String>? componentName;
  final String? action;
  final String? category;
  final String? component;

  Intent(
      {this.action,
      this.packageName,
      this.category,
      this.component,
      this.componentName});

  Intent putExtra(String key, Object value) {
    _kv[key] = value;
    return this;
  }

  Intent putMap(Map<String, Object?>? map) {
    if (map != null) {
      map.forEach((key, value) {
        if (key.isNotBlank) {
          _kv[key] = value;
        }
      });
    }
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
    _appendOptionalParameter(sb, '-p', packageName);
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
