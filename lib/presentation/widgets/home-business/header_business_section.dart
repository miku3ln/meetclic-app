import 'package:flutter/material.dart';
import '../../../domain/entities/business.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/domain/entities/business_data.dart';

class HeaderBusinessSection extends StatelessWidget {
  final BusinessData businessManagementData;
  final double heightTotal ;
  const HeaderBusinessSection({super.key,required this.businessManagementData,required this.heightTotal});

  Future<void> shareData() async {
    try {
      final imageUrl="https://meetclic.com/public/uploads/frontend/templateBySource/1750454099_logo-one.png";
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/shared_image.png';
        // 3. Guardar archivo local
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        final data = businessManagementData;
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Mira esta empresa en MeetClic: https://meetclic.com/${data.business.pageUrl.replaceAll(" ", "").toLowerCase()} Descubre esta empresa en MeetClic',
          subject: '',
        );
      }

    } catch (e) {
      print('Error al compartir: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    final business=businessManagementData.business;
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

              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < businessManagementData.business.distance ? Icons.star : Icons.star_border,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  );
                }),
              ),
              Text(business.businessName,
                style: TextStyle(
                  color:  theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: theme.textTheme.titleLarge?.fontSize
                ),
              ),
              const SizedBox(height: 6),
              Text(
                business.phoneValue,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 100, // 🔍 aumenta el tamaño aquí
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: DecorationImage(
                image: NetworkImage(businessManagementData.business.sourceLogo),
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
          top: 100, // 📌 Ajusta esta posición para que quede justo debajo del logo
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
          top: 120, // Ajusta esta altura según tu diseño
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                _MetricItem(icon: Icons.person, label:       appLocalizations.translate('gamingDataTitle.newsRegisterCount'), value: 10),
                _MetricItem(icon: Icons.emoji_people, label:appLocalizations.translate('gamingDataTitle.customerCount'), value: 10),
                _MetricItem(icon: Icons.emoji_events, label: appLocalizations.translate('gamingDataTitle.rewardsWonCount'), value: 2),
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
    final theme = Theme.of(context);

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
