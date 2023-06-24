import 'package:flutter/material.dart';
import '../commands/adb.dart';
import '../widgets/console.dart';

abstract class BaseStatelessWidget extends StatelessWidget {
  @protected
  final Adb adb;

  @protected
  final ConsoleController consoleController;

  const BaseStatelessWidget(this.adb, this.consoleController, {super.key});
}
