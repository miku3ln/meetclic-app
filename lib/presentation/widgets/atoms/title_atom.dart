import 'package:flutter/material.dart';
import 'atom_styles.dart';

class TitleAtom extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TitleAtom({required this.text, this.style, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? AtomStyles.titleTextStyle,
      textAlign: TextAlign.center,
    );
  }
}