import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final TextAlign textAlign;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const TitleWidget({
    Key? key,
    required this.title,
    this.textAlign = TextAlign.left,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,

        fontWeight: fontWeight,
        color: color ?? Colors.black,  // Usa color personalizado o negro por defecto
      ),
    );
  }
}
