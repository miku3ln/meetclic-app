import 'package:flutter/material.dart';

class DropdownSelector extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  DropdownSelector({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedValue,
      isExpanded: true,
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
