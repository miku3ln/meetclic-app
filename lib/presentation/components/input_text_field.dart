import 'package:flutter/material.dart';
class InputTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  InputTextField({
    required this.hintText,
    this.controller,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final textController = controller ?? TextEditingController();

    return TextField(
      controller: textController,
      onChanged: onChanged,
      decoration: InputDecoration(hintText: hintText),
      keyboardType: keyboardType,
    );
  }
}
