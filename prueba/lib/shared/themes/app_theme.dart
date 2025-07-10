import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.azulClic,
      scaffoldBackgroundColor: AppColors.grisOscuro,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.moradoSuave,
        foregroundColor: AppColors.blanco,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.azulClic,
        secondary: AppColors.amarilloVital,
        background: AppColors.grisOscuro,
        surface: AppColors.moradoSuave,
        onPrimary: AppColors.blanco,
        onSecondary: AppColors.grisOscuro,
        onBackground: AppColors.blanco,
        onSurface: AppColors.blanco,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.blanco),
        titleLarge: TextStyle(color: AppColors.blanco, fontSize: 20),
      ),
      iconTheme: const IconThemeData(color: AppColors.blanco),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.amarilloVital,
      ),
    );
  }
}
