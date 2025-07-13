import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.azulClic,
      scaffoldBackgroundColor: AppColors.grisOscuro,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.moradoSuave,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.blanco,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: ColorScheme.dark(
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
        displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.w400, height: 64.0, letterSpacing: -0.25),
        displayMedium: TextStyle(fontSize: 45.0, fontWeight: FontWeight.w400, height: 52.0),
        displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w400, height: 44.0),
        headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w400, height: 40.0),
        headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w400, height: 36.0),
        headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400, height: 32.0),
        titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400, height: 28.0),
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, height: 24.0),
        titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, height: 20.0),
        bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, height: 24.0),
        bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, height: 20.0),
        bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, height: 16.0),
        labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, height: 20.0),
        labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, height: 16.0),
        labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, height: 16.0),
      ),
      iconTheme: IconThemeData(color: AppColors.blanco),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.azulClic,
        textTheme: ButtonTextTheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.amarilloVital,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grisOscuro,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.azulClic, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.amarilloVital, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.blanco),
        hintStyle: TextStyle(color: AppColors.blanco.withOpacity(0.6)),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.grisOscuro,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shadowColor: AppColors.azulClic,
      ),
      hoverColor: AppColors.azulClic.withOpacity(0.8),
      highlightColor: AppColors.azulClic.withOpacity(0.5),
    );
  }

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.azulClic,
      scaffoldBackgroundColor: AppColors.blanco,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.moradoSuave,
        foregroundColor: AppColors.grisOscuro,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.grisOscuro,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.azulClic,
        secondary: AppColors.amarilloVital,
        background: AppColors.blanco,
        surface: AppColors.moradoSuave,
        onPrimary: AppColors.blanco,
        onSecondary: AppColors.grisOscuro,
        onBackground: AppColors.grisOscuro,
        onSurface: AppColors.grisOscuro,
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
        bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, height: 24.0),
        bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, height: 20.0),
        bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, height: 16.0),
        labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, height: 20.0),
        labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, height: 16.0),
        labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, height: 16.0),
      ),
      iconTheme: IconThemeData(color: AppColors.grisOscuro),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.azulClic,
        textTheme: ButtonTextTheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.amarilloVital,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanco.withOpacity(0.1),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.azulClic, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.amarilloVital, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.grisOscuro),
        hintStyle: TextStyle(color: AppColors.grisOscuro.withOpacity(0.6)),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.blanco,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shadowColor: AppColors.azulClic,
      ),
      hoverColor: AppColors.azulClic.withOpacity(0.8),
      highlightColor: AppColors.azulClic.withOpacity(0.5),
    );
  }
}
