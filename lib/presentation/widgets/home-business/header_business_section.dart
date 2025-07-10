import 'package:flutter/material.dart';
import '../../../domain/entities/business.dart';

class HeaderBusinessSection extends StatelessWidget {
  final BusinessData businessData;
  const HeaderBusinessSection({super.key,required this.businessData});

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
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(businessData.business.imageLogo),
          ),
        ),
      ],
    );
  }
}
