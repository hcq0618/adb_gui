import 'package:flutter/material.dart';

class Console extends StatefulWidget {
  final ConsoleController? controller;

  const Console({super.key, this.controller});

  @override
  State<Console> createState() => _ConsoleState();
}

class ConsoleController {
  late _ConsoleState _state;

  outputConsole(String output) {
    _state._outputConsole(output);
  }

  clearConsole() {
    _state._clearConsole();
  }
}

class _ConsoleState extends State<Console> {
  String _consoleOutput = "";
  final ScrollController _scrollController = ScrollController();

  _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    });
  }

  _outputConsole(String output) {
    setState(() {
      _consoleOutput = "$_consoleOutput\n$output";
    });
    _scrollToEnd();
  }

  _clearConsole() {
    setState(() {
      _consoleOutput = "";
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: double.infinity,
      height: 200,
      color: Colors.black,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SelectableText(
          _consoleOutput,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
