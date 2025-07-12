import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meetclic/shared/models/app_config.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';


void showTopLanguageModal(
    BuildContext context,
    Function(String) onChanged,
    List<MenuTabUpItem> menuTabUpItems,
    void Function(VoidCallback fn) setStateFn,
    ) {
  final overlay = Overlay.of(context);
  final screenSize = MediaQuery.of(context).size;
  final modalHeight = screenSize.height * 0.3;
  final colorScheme = Theme.of(context).colorScheme;
  final config = Provider.of<AppConfig>(context, listen: false);
  final currentLocale = config.locale.languageCode;

  final Map<String, String> languages = {
    'es': AppLocalizations.of(context).translate('language.spanish'),
    'en': AppLocalizations.of(context).translate('language.english'),
    'it': AppLocalizations.of(context).translate('language.kichwa'),
  };

  final Map<String, String> flags = {
    'es': 'assets/flags/es.png',
    'en': 'assets/flags/en.png',
    'it': 'assets/flags/ki.png',
  };

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (entry.mounted) entry.remove();
          },
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        Positioned(
          top: 73,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: screenSize.width,
                  height: modalHeight,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('language.select'),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: languages.entries.map((entryLang) {
                            final isSelected = entryLang.key == currentLocale;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // ✅ Cambiar idioma
                                  onChanged(entryLang.key);

                                  // ✅ Cambiar bandera del ítem de menú
                                  final newFlag = flags[entryLang.key]!;

                                  final menuItemIdiomaActualizado = MenuTabUpItem(
                                    id: 1,
                                    name: 'idioma',
                                    asset: newFlag,
                                    number: 3,
                                    onTap: () => showTopLanguageModal(
                                      context,
                                      onChanged,
                                      menuTabUpItems,
                                      setStateFn,
                                    ),
                                  );

                                  // ✅ Actualizar estado de HomeScreenState
                                  setStateFn(() {
                                    menuTabUpItems[0] = menuItemIdiomaActualizado;
                                  });

                                  // ✅ Cerrar el modal
                                  if (entry.mounted) {
                                    entry.remove();
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    border: isSelected
                                        ? Border.all(
                                      color: colorScheme.primary,
                                      width: 3,
                                    )
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        flags[entryLang.key]!,
                                        width: 50,
                                        height: 35,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        entryLang.value,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);
}
