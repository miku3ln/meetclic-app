import 'package:flutter/material.dart';
import 'app/init_mock_app.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 🔥 Fuerza el fondo blanco en el motor de Flutter desde el arranque:
  WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
  runApp(const InitMockApp());
}
