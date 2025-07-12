import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../shared/models/app_config.dart';
import '../shared/location/app_localizations.dart';
import '../shared/themes/app_theme.dart';
import '../presentation/pages/splash_screen.dart';

class InitMockApp extends StatelessWidget {
  const InitMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppConfig(),
      child: Consumer<AppConfig>(
        builder: (context, config, _) {
          return MaterialApp(
            title: 'Meetclic',
            theme: AppTheme.darkTheme,
            locale: config.locale,
            supportedLocales: const [
              Locale('es'), // Español
              Locale('en'), // Inglés
              Locale('ki'), // Kichwa si agregas un JSON: ki.json
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate, // 🧠 Tu clase de traducción personalizada
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
