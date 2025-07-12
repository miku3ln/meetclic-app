
import 'package:flutter/material.dart';
import 'index.dart';
import 'package:meetclic/data/data-sources/module_api_fake.dart';
import '../../../domain/entities/status_item.dart';
import 'package:app_links/app_links.dart'; // ✅ reemplaza uni_links
import '../../shared/localization/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ModuleApiFake api = ModuleApiFake();
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => loadResources());
  }



  Future<void> loadResources() async {
    try {
      await precacheImage(const AssetImage('assets/images/splash_bg.png'), context);

      final modules = await api.getModules();
      final itemsStatus = [
        StatusItem(icon: Icons.local_fire_department, color: Colors.orange, value: '5'),
        StatusItem(icon: Icons.diamond, color: Colors.cyan, value: '2480'),
        StatusItem(icon: Icons.emoji_events, color: Colors.orange, value: '2'),
      ];

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(modules: modules, itemsStatus: itemsStatus),
        ),
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
          Image.asset('assets/images/splash_bg.png', fit: BoxFit.contain),
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
                    AppLocalizations.of(context).translate('loading')+'...',
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
