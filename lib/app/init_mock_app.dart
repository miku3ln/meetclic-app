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
            theme: AppTheme.lightTheme,
            locale: config.locale,

            supportedLocales: const [
              Locale('es'), // Español
              Locale('en'), // Inglés
              Locale('it'), // Kichwa personalizado
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate, // Tu propio loader de JSONs
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // 👇 Este bloque previene el crash para 'ki'
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale != null) {
                // Si es 'ki', retornamos 'es' para MaterialLocalizations
                if (locale.languageCode == 'qu') {
                  return const Locale('qu'); // ⚠️ aún cargamos tu JSON personalizado
                }

                for (final supported in supportedLocales) {
                  if (supported.languageCode == locale.languageCode) {
                    return supported;
                  }
                }
              }
              return supportedLocales.first; // fallback por defecto
            },
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
