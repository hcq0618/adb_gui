import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'callbacks.dart';

class CommandValueField extends StatefulWidget {
  late final TextEditingController _controller;
  final double width;
  final String hint;
  final String buttonText;
  final TextCallback onPressed;
  final VoidCallback? onHelpPressed;
  final String? helpUrl;

  CommandValueField(
      {super.key,
      TextEditingController? controller,
      this.width = 80,
      required this.hint,
      required this.buttonText,
      required this.onPressed,
      this.onHelpPressed,
      this.helpUrl}) {
    _controller = controller ?? TextEditingController();
  }

  @override
  State<StatefulWidget> createState() => _CommandValueFieldState();
}

class _CommandValueFieldState extends State<CommandValueField> {
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
        Visibility(
          visible:
              widget.onHelpPressed != null || widget.helpUrl.isNotNullOrEmpty,
          child: IconButton(
            onPressed: widget.onHelpPressed ??
                () async {
                  final url = Uri.parse(widget.helpUrl.orEmpty());
                  await launchUrl(url);
                },
            icon: const Icon(Icons.help),
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
