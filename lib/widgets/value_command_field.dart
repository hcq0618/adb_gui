import 'package:flutter/material.dart';
import 'callbacks.dart';

class ValueCommandField extends StatefulWidget {
  late final TextEditingController _controller;
  final double width;
  final String hint;
  final String buttonText;
  final TextCallback onPressed;

  ValueCommandField(
      {super.key,
      TextEditingController? controller,
      this.width = 80,
      required this.hint,
      required this.buttonText,
      required this.onPressed}) {
    _controller = controller ?? TextEditingController();
  }

  @override
  State<StatefulWidget> createState() => _ValueCommandFieldState();
}

class _ValueCommandFieldState extends State<ValueCommandField> {
  @override
  void dispose() {
    widget._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: widget.width,
          child: TextField(
            controller: widget._controller,
            decoration: InputDecoration(hintText: widget.hint),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            widget.onPressed(widget._controller.text);
          },
          child: Text(widget.buttonText),
        ),
      ],
    );
  }
}
