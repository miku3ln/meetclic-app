import 'package:flutter/material.dart';
import 'atom_styles.dart';

class CheckboxAtom extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;
  final Widget? label;

  const CheckboxAtom({
    required this.value,
    this.onChanged,
    this.activeColor,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? AtomStyles.activeColor,
      title: label,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
