import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.azulClic,
      scaffoldBackgroundColor: AppColors.blanco,
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

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.azulClic,
      scaffoldBackgroundColor: AppColors.blanco,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.moradoSuave,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.grisOscuro,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.azulClic,
        secondary: AppColors.amarilloVital,
        background: AppColors.blanco,
        surface: AppColors.moradoSuave,
        onPrimary: AppColors.blanco,
        onSecondary: AppColors.grisOscuro,
        onBackground: AppColors.blanco,
        onSurface: AppColors.blanco,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.w400, height: 64.0, letterSpacing: -0.25),
        displayMedium: TextStyle(fontSize: 45.0, fontWeight: FontWeight.w400, height: 52.0),
        displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w400, height: 44.0),
        headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w400, height: 40.0),
        headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w400, height: 36.0),
        headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400, height: 32.0),
        titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400, height: 28.0),
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, height: 24.0),
        titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, height: 20.0),
        bodyMedium: TextStyle(color: AppColors.blanco),
        bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, height: 24.0),
       bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, height: 16.0),
      labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, height: 20.0),
      labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, height: 16.0),
      labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, height: 16.0),

      ),
      iconTheme: const IconThemeData(color: AppColors.blanco),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.amarilloVital,
      ),
    );
  }
}
