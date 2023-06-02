import 'package:adb_gui/commands/adb_command.dart';
import 'package:adb_gui/commands/adb_components.dart';
import 'package:adb_gui/commands/adb_packages.dart';

import 'adb_devices.dart';

class Adb extends AdbCommand with AdbDevices, AdbPackages, AdbComponents {}
