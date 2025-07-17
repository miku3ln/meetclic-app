import 'package:flutter/material.dart';
import 'atom_styles.dart';
class InputTextAtom extends StatelessWidget {
  final String? label;
  final TextInputType keyboardType;
  final bool obscureText;
  final double? height;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller; // ✅ Nuevo: Controller opcional

  const InputTextAtom({
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.height,
    this.labelStyle,
    this.textStyle,
    this.decoration,
    this.onChanged,
    this.validator,
    this.controller, // ✅ Lo añades aquí también
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller, // ✅ Permite usar el controller si se pasa
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        style: (textStyle ?? AtomStyles.inputTextStyle).copyWith(
          color: theme.textTheme.bodyMedium?.color,
        ),
        decoration: decoration ??
            InputDecoration(
              labelText: label,
              labelStyle: (labelStyle ?? AtomStyles.labelTextStyle).copyWith(
                color: theme.textTheme.titleSmall?.color,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                ),
                borderRadius: AtomStyles.inputBorder.borderRadius,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.secondary,
                  width: 1.5,
                ),
                borderRadius: AtomStyles.inputBorder.borderRadius,
              ),
            ),
      ),
    );
  }
}
