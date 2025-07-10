import 'package:flutter/material.dart';
import 'package:prueba/shared/themes/app_theme.dart';
import '../presentation/pages/splash_screen.dart';


class InitMockApp extends StatelessWidget {
  const InitMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meetclic',
      theme: AppTheme.darkTheme, // <- tema con tus colores oficiales
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
