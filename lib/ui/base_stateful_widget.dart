import 'package:flutter/material.dart';

import '../commands/adb.dart';
import '../widgets/console.dart';

abstract class BaseStatefulWidget extends StatefulWidget {
  final Adb _adb;
  final ConsoleController _consoleController;

  const BaseStatefulWidget(this._adb, this._consoleController, {super.key});
}

abstract class BaseState<T extends BaseStatefulWidget> extends State<T> {
  Adb get adb => widget._adb;

  ConsoleController get consoleController => widget._consoleController;

  Widget buildDivider() {
    return const VerticalDivider(
      width: 30,
      thickness: 1,
      indent: 10,
      endIndent: 10,
      color: Colors.grey,
    );
  }
}
