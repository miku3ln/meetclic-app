import 'package:flutter/material.dart';
import 'package:meetclic/shared/themes/app_colors.dart'; // ajusta si tu ruta es distinta

/// -------------------- Tile de palabra --------------------
class WordTile extends StatelessWidget {
  final WordItem item;
  final VoidCallback onPlay;

  const WordTile({required this.item, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            item.image,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.grisOscuro,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.moradoSuave,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: onPlay,
          icon: const Icon(Icons.volume_up_rounded),
          color: AppColors.azulClic,
          tooltip: 'Reproducir',
        ),
      ),
    );
  }
}

/// -------------------- Modelo auxiliar --------------------
class WordItem {
  final String image;
  final String title;
  final String subtitle;
  final String description;

  const WordItem({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
