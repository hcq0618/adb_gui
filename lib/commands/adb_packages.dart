import 'package:adb_gui/commands/adb_command.dart';

mixin AdbPackages on AdbCommand {
  Stream<String> listPackages(String parameter, {String filter = ''}) async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell pm list packages $parameter $filter");
  }

  Stream<String> installPackage(String parameter, String path) async* {
    // https://linuxhint.com/deal-spaces-file-path-linux/
    yield* command(
        "adb ${selectedDeviceParameter()} install $parameter '$path'");
  }

  Stream<String> uninstallPackage(String packageName,
      {bool keepData = false}) async* {
    String parameter;
    if (keepData) {
      parameter = '-k';
    } else {
      parameter = '';
    }
    yield* command(
        "adb ${selectedDeviceParameter()} uninstall $parameter $packageName");
  }

  Stream<String> clearData(String packageName) async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell pm clear $packageName");
  }

  Stream<String> showPackageDetails(String packageName) async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell dumpsys package $packageName");
  }

  Stream<String> showPackagePath(String packageName) async* {
    yield* command(
        "adb ${selectedDeviceParameter()} shell pm path $packageName");
  }
}

enum ListPackagesParameter {
  all(''),
  withApk('-f'),
  withInstaller('-i'),
  onlyDisabled('-d'),
  onlyEnabled('-e'),
  onlySystem('-s'),
  only3rdParty('-3'),
  includeUninstalled('-u');

  final String value;

  const ListPackagesParameter(this.value);
}

enum InstallPackageParameter {
  normal(''),
  toProtectedDir('-l'),
  toSDCard('-s'),
  allowOverwrite('-r'),
  allowTestOnly('-t'),
  allowDowngrade('-d'),
  grantAllPermissions('-g'),
  armeabiV7a('armeabi-v7a'),
  arm64V8a('arm64-v8a'),
  v86('v86'),
  x86_64('x86_64');

  final String value;

  const InstallPackageParameter(this.value);
}
