import 'package:flutter/material.dart';

class AppColors {
  // Colores principales de la marca
  static const Color azulClic = Color(0xFF4C4CFF);
  static const Color amarilloVital = Color(0xFFFFCC00);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisOscuro = Color(0xFF2C2C2C);
  static const Color moradoSuave = Color(0xFF5C5CFF);

  // Colores complementarios (basados en los principales)
  static const Color complementoAzul = Color(0xFFFF4C4C);  // Complementario al azulClic (rojo)
  static const Color complementoAmarillo = Color(0xFF005CFF);  // Complementario al amarilloVital (azul)
  static const Color complementoMorado = Color(0xFFFF9F00);  // Complementario al moradoSuave (amarillo)

  // Colores análogos
  static const Color analogoAzul1 = Color(0xFF0000FF); // Azul fuerte
  static const Color analogoAzul2 = Color(0xFF2C2CFF); // Azul oscuro

  static const Color analogoAmarillo1 = Color(0xFFFF9900); // Naranja claro
  static const Color analogoAmarillo2 = Color(0xFFFFDB00); // Amarillo más cálido

  // Colores triádicos (usando el círculo cromático)
  static const Color triadico1 = Color(0xFFFF0066); // Un tono rojo intenso
  static const Color triadico2 = Color(0xFF00FF99); // Un verde aqua

  // Colores adicionales
  static const Color rojoMarca = Color(0xFFB80000); // Color de alerta o énfasis
  static const Color verdeSalud = Color(0xFF28A745); // Color para bienestar y salud

  // Fondo degradado
  static const Gradient fondoGradiente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [azulClic, moradoSuave],
  );
}
