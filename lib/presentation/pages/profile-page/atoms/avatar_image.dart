import 'package:flutter/material.dart';



class AvatarCard extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final ImageProvider image;
  final VoidCallback onSettingsTap;

  const AvatarCard({
    super.key,
    this.width = double.infinity,
    this.height = 200,
    required this.backgroundColor,
    required this.image,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo con imagen rectangular
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            image: DecorationImage(
              image: image,
          //    fit: BoxFit.cover,

              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        // Botón configuración flotante, estilo circular
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, size: 20, color: Colors.black),
              onPressed: onSettingsTap,
              tooltip: 'Configuración',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}
