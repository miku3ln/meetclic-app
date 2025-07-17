import 'package:flutter/material.dart';
import 'atom_styles.dart';

class DropdownAtom extends StatelessWidget {
  final String? label;
  final List<String> items;
  final String value;
  final ValueChanged<String?>? onChanged;
  final TextStyle? labelStyle;
  final TextStyle? itemStyle;
  final double? height;

  const DropdownAtom({
    this.label,
    required this.items,
    required this.value,
    this.onChanged,
    this.labelStyle,
    this.itemStyle,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? AtomStyles.dropdownHeight,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: itemStyle ?? AtomStyles.dropdownItemStyle),
        ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: labelStyle ?? AtomStyles.labelTextStyle,
          border: AtomStyles.inputBorder,
        ),
      ),
    );
  }
}
