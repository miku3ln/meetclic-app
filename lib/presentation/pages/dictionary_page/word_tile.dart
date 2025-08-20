import 'package:flutter/material.dart';
import 'package:meetclic/shared/themes/app_colors.dart';

import 'models/word_item.dart';

class WordTile extends StatelessWidget {
  final WordItem item;
  final VoidCallback onPlay;

  const WordTile({super.key, required this.item, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Entrada de diccionario: ${item.title}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.image,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.azulClic.withOpacity(.08),
                  alignment: Alignment.center,
                  child: const Icon(Icons.menu_book_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Palabra + botón audio
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title, // ej. achachay
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.grisOscuro,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onPlay,
                        icon: const Icon(Icons.volume_up_rounded),
                        color: AppColors.azulClic,
                        tooltip: 'Reproducir pronunciación',
                      ),
                    ],
                  ),

                  // Fonema (entre corchetes)
                  if ((item.phoneme ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '[${item.phoneme}]',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // Traducciones como chips
                  Wrap(
                    spacing: 6,
                    runSpacing: -6,
                    children: [
                      if ((item.translationEs ?? item.subtitle).isNotEmpty)
                        _TagChip(
                          text: item.translationEs ?? item.subtitle,
                          icon: Icons.translate_rounded,
                          bg: AppColors.amarilloVital.withOpacity(.15),
                          fg: AppColors.grisOscuro,
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Descripción breve / uso en contexto
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.25),
                  ),

                  const SizedBox(height: 8),

                  // Clases gramaticales
                  if (item.classes.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: item.classes
                          .map((c) => _ClassPill(text: c))
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _TagChip({
    required this.text,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassPill extends StatelessWidget {
  final String text;
  const _ClassPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.moradoSuave.withOpacity(.10),
        border: Border.all(color: AppColors.moradoSuave.withOpacity(.35)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text, // ej. "Adj." "Interj." "Sust."
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.moradoSuave,
          fontWeight: FontWeight.w800,
          letterSpacing: .2,
        ),
      ),
    );
  }
}
