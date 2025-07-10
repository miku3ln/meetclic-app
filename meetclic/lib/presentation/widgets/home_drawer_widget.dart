// presentation/widgets/home_drawer_widget.dart
import 'package:flutter/material.dart';

class HomeDrawerWidget extends StatelessWidget {
  const HomeDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.surface),
            child: Text('Unit Menu', style: theme.textTheme.titleLarge),
          ),
          ListTile(
            leading: Icon(Icons.play_arrow, color: theme.iconTheme.color),
            title: Text('Start Lesson', style: theme.textTheme.bodyMedium),
          ),
          ListTile(
            leading: Icon(Icons.history, color: theme.iconTheme.color),
            title: Text('Progress', style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
