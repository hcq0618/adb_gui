import 'package:flutter/material.dart';

class RefreshButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const RefreshButton({super.key, required this.onPressed});

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton> {
  double turns = 0.0;

  void _changeRotation() {
    setState(() => turns += 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: AnimatedRotation(
          turns: turns,
          duration: const Duration(milliseconds: 500),
          child: const Icon(Icons.sync_outlined),
        ),
        onPressed: () {
          _changeRotation();
          widget.onPressed?.call();
        });
  }
}
