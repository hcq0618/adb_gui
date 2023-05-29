import 'package:flutter/material.dart';
import 'callbacks.dart';

class ValueCommandField extends StatefulWidget {
  final String hint;
  final String buttonText;
  final TextCallback onPressed;

  const ValueCommandField(
      {super.key,
      required this.hint,
      required this.buttonText,
      required this.onPressed});

  @override
  State<StatefulWidget> createState() => _ValueCommandField();
}

class _ValueCommandField extends State<ValueCommandField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: widget.hint),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            widget.onPressed(_controller.text);
          },
          child: Text(widget.buttonText),
        ),
      ],
    );
  }
}
