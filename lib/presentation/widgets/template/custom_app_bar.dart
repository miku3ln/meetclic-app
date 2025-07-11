import 'package:flutter/material.dart';
import '../../../domain/entities/status_item.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<StatusItem> items;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(title),
      backgroundColor: theme.primaryColor,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Row(
            children: items
                .map(
                  (item) => Padding(
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
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }
}
