import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(text),
    );
    return isSecondary
        ? OutlinedButton(onPressed: onPressed, child: child)
        : ElevatedButton(onPressed: onPressed, child: child);
  }
}
