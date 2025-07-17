import 'package:flutter/material.dart';
import 'atom_styles.dart';

class SwitchToggleAtom extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveThumbColor;

  const SwitchToggleAtom({
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveThumbColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? AtomStyles.activeColor,
      inactiveThumbColor: inactiveThumbColor ?? AtomStyles.inactiveColor,
    );
  }
}
