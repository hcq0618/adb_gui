import 'package:flutter/material.dart';

import '../commands/adb.dart';
import '../widgets/console.dart';

abstract class BaseStatefulWidget extends StatefulWidget {
  final Adb _adb;
  final ConsoleController _consoleController;

  const BaseStatefulWidget(this._adb, this._consoleController, {super.key});
}

abstract class BaseState<T extends BaseStatefulWidget> extends State<T> {
  @protected
  Adb get adb => widget._adb;

  @protected
  ConsoleController get consoleController => widget._consoleController;
}
