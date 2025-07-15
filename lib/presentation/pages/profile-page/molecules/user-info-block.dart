import 'package:flutter/material.dart';

class UserInfoBlock extends StatelessWidget {
  const UserInfoBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text('Miguel Alba',
            style: TextStyle(color: theme.primaryColor)),
        const SizedBox(height: 4),
        Text('@MIGUELAlba356038', style: TextStyle(color: theme.colorScheme.surface)),
        const SizedBox(height: 4),
        Text('Miembro desde Mayo 2025', style: TextStyle(color: theme.colorScheme.onBackground)),
      ],
    );
  }
}
