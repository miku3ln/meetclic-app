import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:prueba/data/data-sources/module_api_fake.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ModuleApiFake api = ModuleApiFake();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadResources());
  }

  Future<void> loadResources() async {
    try {
      // Precarga imagen para que no falle en HomeScreen
      await precacheImage(const AssetImage('assets/images/splash_bg.png'), context);

      // Llamada real (simulada desde fake API, pero sin delay artificial tuyo)
      final modules = await api.getModules();

      if (!mounted) return;

      // Solo navegamos cuando TODO está cargado
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(modules: modules)),
      );
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_bg.png',
            fit: BoxFit.contain,
          ),
          Container(
            color: colorScheme.background.withOpacity(0.4),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      color: colorScheme.onBackground,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
