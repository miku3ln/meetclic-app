import 'package:flutter/material.dart';
import 'header_business_section.dart';
import 'task_list_business_section.dart';
import 'activity_list_business_section.dart';
import '../../../domain/entities/business.dart';

class HomeBusinessSection extends StatelessWidget {
  final BusinessData businessData;

  const HomeBusinessSection({super.key, required this.businessData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Fondo con header ampliado
        Container(
          height: MediaQuery.of(context).size.height * 0.32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
          width: double.infinity,
          child: HeaderBusinessSection(businessData: businessData),
        ),

        // Contenido principal desplazado hacia abajo
        Padding(
          padding: const EdgeInsets.only(top: 180), // Para que flote sobre el header
          child: Column(
            children: [
               TaskListBusinessSection(businessData:businessData),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Today\'s plan', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFFE0FFF2),
                      child: Text('75%', style: TextStyle(color: Colors.teal, fontSize: 12)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
               Expanded(child: ActivityListBusiness(businessData:businessData)),
            ],
          ),
        ),
      ],
    );
  }
}
