import 'package:flutter/material.dart';
import '../../../domain/entities/business.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // 👈 Importa esto
import 'package:share_plus/share_plus.dart';
class HeaderBusinessSection extends StatelessWidget {
  final BusinessData businessData;
  const HeaderBusinessSection({super.key,required this.businessData});

  void shareData() {
    final data = businessData;
    Share.share(
      'Mira esta empresa en MeetClic: https://meetclic.com ${data.business.name}',
      subject: 'Descubre esta empresa en MeetClic',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final business=businessData.business;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05), // 👈 aquí el 2%
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < businessData.business.starCount ? Icons.star : Icons.star_border,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  );
                }),
              ),
              Text(business.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                business.description,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 80, // 🔍 aumenta el tamaño aquí
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: DecorationImage(
                image: NetworkImage(businessData.business.imageLogo),
                fit: BoxFit.cover, // ✅ asegura que se vea bien sin distorsión
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 90, // 📌 Ajusta esta posición para que quede justo debajo del logo
          right: 26,
          child: GestureDetector(
            onTap: () {
              // Aquí va tu lógica de compartir
              shareData();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.share, size: 20, color: Colors.black54),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Positioned(
          top: 150, // Ajusta esta altura según tu diseño
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _MetricItem(icon: Icons.person, label: "Nuevas Visitas", value: 10),
                _MetricItem(icon: Icons.emoji_people, label: "Clientes satisfechos", value: 10),
                _MetricItem(icon: Icons.emoji_events, label: "Premios Ganados", value: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 30,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
