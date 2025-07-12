import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/status_item.dart';
import '../../../shared/models/app_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<StatusItem> items;

  const CustomAppBar({super.key, required this.title, required this.items});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appConfig = Provider.of<AppConfig>(context);

    return AppBar(
      backgroundColor: theme.primaryColor,
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: LanguageFlagDropdown(
            currentLocale: appConfig.locale.languageCode,
            onChanged: (String code) =>
                appConfig.setLocale(Locale(code)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Row(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Icon(item.icon, color: item.color, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

}

class LanguageFlagDropdown extends StatelessWidget {
  final String currentLocale;
  final Function(String) onChanged;

  const LanguageFlagDropdown({
    super.key,
    required this.currentLocale,
    required this.onChanged,
  });

  static const Map<String, String> flagPaths = {
    'es': 'assets/flags/es.png',
    'en': 'assets/flags/en.png',
    'it': 'assets/flags/ki.png',
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isDense: true,
        // ✅ Reduce altura y padding
        value: currentLocale,
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: flagPaths.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Image.asset(entry.value, width: 30, height: 20),
          );
        }).toList(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        dropdownColor: Colors.white,
      ),
    );
  }
}
