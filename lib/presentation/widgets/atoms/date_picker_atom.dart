import 'package:flutter/material.dart';
import 'atom_styles.dart';

class DatePickerAtom extends StatelessWidget {
  final String label;
  final String? selectedDateText;
  final VoidCallback onTap;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final Color? iconColor;

  const DatePickerAtom({
    required this.label,
    this.selectedDateText,
    required this.onTap,
    this.labelStyle,
    this.textStyle,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: labelStyle ?? AtomStyles.datePickerLabelStyle,
      ),
      subtitle: Text(
        selectedDateText ?? 'Seleccionar fecha',
        style: textStyle ?? AtomStyles.datePickerTextStyle,
      ),
      trailing: Icon(Icons.calendar_today, color: iconColor),
      onTap: onTap,
    );
  }
}
