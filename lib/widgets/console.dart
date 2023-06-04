import 'package:flutter/material.dart';

class Console extends StatefulWidget {
  final ConsoleController controller;

  const Console(this.controller, {super.key});

  @override
  State<Console> createState() => _ConsoleState();
}

class ConsoleController {
  final _consoleOutput = ValueNotifier('');
  final ScrollController _scrollController = ScrollController();

  ConsoleController();

  void outputConsole(String output) {
    _consoleOutput.value = "${_consoleOutput.value}\n$output";
    _scrollToEnd();
  }

  void outputStreamConsole(Stream<String> output) {
    output.listen(
      (out) {
        outputConsole(out);
      },
      cancelOnError: true,
    );
  }

  void _scrollToEnd() {
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

  void clearConsole() {
    _consoleOutput.value = '';
  }

  void _dispose() {
    _consoleOutput.dispose();
    _scrollController.dispose();
  }
}

class _ConsoleState extends State<Console> {
  @override
  void dispose() {
    widget.controller._dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: double.infinity,
      height: 200,
      color: Colors.black,
      child: ValueListenableBuilder(
        valueListenable: widget.controller._consoleOutput,
        builder: (context, value, child) {
          return SingleChildScrollView(
            controller: widget.controller._scrollController,
            child: SelectableText(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
