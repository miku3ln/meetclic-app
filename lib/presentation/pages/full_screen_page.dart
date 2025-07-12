import 'package:flutter/material.dart';
import '../../../domain/entities/status_item.dart';
import '../../../presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
class FullScreenPage extends StatelessWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;
  const FullScreenPage({super.key, required this.title,required this.itemsStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // usa el color global
      appBar: CustomAppBar(title: title, items: itemsStatus),
      body: Center(
        child: Text(
          '$title Screen',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary, // se puede personalizar desde el Theme
          ),
        ),
      ),
    );
  }
}
