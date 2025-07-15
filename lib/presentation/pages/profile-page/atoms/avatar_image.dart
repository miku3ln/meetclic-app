import 'package:flutter/material.dart';

class AvatarImage extends StatelessWidget {
  final double size;
  const AvatarImage({this.size = 50, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: size,
      backgroundColor: theme.colorScheme.primary,
      child: Icon(Icons.person, size: size * 0.8, color: theme.colorScheme.onPrimary),
    );
  }
}