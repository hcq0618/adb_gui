import 'package:process_run/shell.dart';

import 'adb_command.dart';

mixin AdbDevices on AdbCommand {
  Future<List<DeviceInfo>> getOnlineDevices() async {
    final output = await shell.run('adb devices');
    final result = <DeviceInfo>[];

    for (var element in output.outLines) {
      if (element.isEmpty) continue;
      if (element == 'List of devices attached') continue;
      if (element == 'no device' || element.contains('offline')) continue;

      final onlineIndex = element.indexOf('device');
      if (onlineIndex >= 0) {
        final serialNumber = element.substring(0, onlineIndex).trim();
        final deviceName = await commandFutureFromStream(
            getDeviceName(serialNumber: serialNumber));
        result.add(DeviceInfo(deviceName, serialNumber));
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

  Stream<String> getAdbVersion() async* {
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

  Stream<String> mockKeyEvent(String keyCode) async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell input keyevent $keyCode");
  }

  Stream<String> getDeviceName({String serialNumber = ""}) async* {
    if (serialNumber.isEmpty) {
      serialNumber = selectedDeviceParameter();
    } else {
      serialNumber = deviceParameter(serialNumber);
    }
    final model =
        await commandFuture("adb $serialNumber shell getprop ro.product.model");
    final manufacturer = await commandFuture(
        "adb $serialNumber shell getprop ro.product.manufacturer");
    yield "$manufacturer $model";
  }

  Stream<String> getScreenResolution() async* {
    yield* command("adb ${selectedDeviceParameter()} shell wm size");
  }

  Stream<String> getScreenDensity() async* {
    yield* command("adb ${selectedDeviceParameter()} shell wm density");
  }

  Stream<String> getAndroidId() async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell settings get secure android_id");
  }

  Stream<String> getAndroidVersion() async* {
    final osVersion = await commandFuture(
        "adb ${selectedDeviceParameter()} shell getprop ro.build.version.release");
    final apiLevel = await commandFuture(
        "adb ${selectedDeviceParameter()} shell getprop ro.build.version.sdk");
    yield "Android $osVersion, API $apiLevel";
  }

  Stream<String> getIpAddress() async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell ifconfig | grep Mask");
  }

  Stream<String> getMemoryInfo() async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell cat /proc/meminfo | grep -e MemTotal -e MemFree");
  }

  Stream<String> monkeyTest(String packageName, int count) async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell monkey -p $packageName -v $count");
  }

  Stream<String> showPIDs() async* {
    yield* command("adb ${selectedDeviceParameter()} shell ps");
  }

  Stream<String> killPID(String pid) async* {
    yield* command("adb ${selectedDeviceParameter()} shell kill $pid");
  }

  Stream<String> showUID(String packageName) async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell dumpsys package $packageName | grep userId=");
  }
}

class DeviceInfo {
  String name;
  String serialNumber;

  DeviceInfo(this.name, this.serialNumber);
}
