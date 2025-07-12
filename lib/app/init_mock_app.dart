import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../presentation/pages/splash_screen.dart';
import '../shared/models/app_config.dart';
import '../shared/themes/app_theme.dart';
import '../shared/localization/app_localizations.dart';

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
            // 🌍 Este bloque es CLAVE:
            supportedLocales: const [
              Locale('es'), // Español
              Locale('en'), // Inglés
              Locale('ki'), // Kichwa
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate, // 👈 Agregado
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
