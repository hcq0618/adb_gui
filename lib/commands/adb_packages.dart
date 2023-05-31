import 'package:adb_gui/commands/adb_command.dart';

mixin AdbPackages on AdbCommand {
  Future<String> packages(String parameter, {String filter = ''}) async {
    return command(
        "adb ${selectedDeviceParameter()} shell pm list packages $parameter $filter");
  }
}

enum PackagesParameter {
  all(''),
  withApk('-f'),
  withInstaller('-i'),
  onlyDisabled('-d'),
  onlyEnabled('-e'),
  onlySystem('-s'),
  only3rdParty('-3'),
  includeUninstalled('-u');

  final String value;

  const PackagesParameter(this.value);
}
