import 'package:flutter/material.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic/shared/providers_session.dart';
import 'package:meetclic/shared/models/app_config.dart';
import 'package:meetclic/presentation/pages/home/modals/language_modal.dart';
import 'package:meetclic/aplication/services/access_manager_service.dart';
import 'package:meetclic/presentation/pages/home/modals/show_view_components.dart';

class MenuTabUpController {
  static List<MenuTabUpItem> buildMenu({
    required BuildContext context,
    required AppConfig config,
    required void Function(void Function()) setStateCallback,
    required SessionService session,
  }) {
    final accessManager = AccessManagerService(context);
    final user = session.currentSession;

    final yapitas = session.isLoggedIn
        ? user?.summary?.yapitas.currentBalance ?? 0
        : 0;
    final yapitasPremium = session.isLoggedIn
        ? user?.summary?.yapitasPremium.currentBalance ?? 0
        : 0;
    final trofeos = session.isLoggedIn ? user?.summary?.trophies.total ?? 0 : 0;
    final cesta = 0;
    final idioma = 3;
    final locale = config.locale.languageCode;

    final itemLanguage = MenuTabUpItem(
      id: 1,
      name: 'idioma',
      asset: 'assets/flags/$locale.png',
      number: idioma,
      onTap: () => showTopLanguageModal(
        context,
        (newLocale) => config.setLocale(Locale(newLocale)),
        [],
        setStateCallback,
      ),
    );

    return [
      itemLanguage,
      _item(
        context,
        'fuego',
        'assets/appbar/yapitas.png',
        yapitas,
        accessManager,
      ),
      _item(
        context,
        'diamante',
        'assets/appbar/yapitas-premium.png',
        yapitasPremium,
        accessManager,
      ),
      _item(
        context,
        'trofeo',
        'assets/appbar/trophy-two.png',
        trofeos,
        accessManager,
      ),
      _item(context, 'cesta', 'assets/appbar/basket.png', cesta, accessManager),
    ];
  }

  static MenuTabUpItem _item(
    BuildContext context,
    String name,
    String asset,
    int count,
    AccessManagerService accessManager,
  ) {
    return MenuTabUpItem(
      id: name.hashCode,
      name: name,
      asset: asset,
      number: count,
      onTap: () async {
        final result = await accessManager.handleAccess(() async {
          showViewComponents(context, (formData) {
            print('🚀 Datos recibidos: $formData');
          });
        });

        if (result.success) {
          print('✅ Acceso concedido o registrado ($name)');
        } else {
          print('❌ Error: ${result.message} ($name)');
        }
      },
    );
  }
}
