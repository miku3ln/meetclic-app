import 'package:flutter/material.dart';

class AppColors {
  static const Color azulClic = Color(0xFF4C4CFF);
  static const Color amarilloVital = Color(0xFFFFCC00);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisOscuro = Color(0xFF1A1C22);
  static const Color moradoSuave = Color(0xFF5C5CFF);

  // Para fondos degradados (opcional)
  static const Gradient fondoGradiente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [azulClic, moradoSuave],
  );
}
