import 'package:flutter/material.dart';
import 'package:meetclic/domain/entities/business_data.dart';

class GamificationBusinessSection extends StatelessWidget {

  final BusinessData businessManagementData;
  const GamificationBusinessSection({super.key, required this.businessManagementData});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Juegos", style: TextStyle(fontSize: 20)),
    );
  }
}
