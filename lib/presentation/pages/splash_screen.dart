import 'package:flutter/material.dart';
import 'package:meetclic/presentation/pages/home/home_page.dart';
import 'package:meetclic/data/data-sources/module_api_fake.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final ModuleApiFake api = ModuleApiFake();
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // Configura la animación
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Inicia carga de recursos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) => loadResources());
  }

  Future<void> loadResources() async {
    try {
      await precacheImage(const AssetImage('assets/images/splash_bg.png'), context);
      _controller.forward(); // inicia animación
      await Future.delayed(const Duration(seconds: 1)); // opcional pero elegante
      final modules = await api.getModules();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(modules: modules),
        ),
      );
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: Image.asset(
                  'assets/images/splash_bg.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              color: colorScheme.background.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
