// Archivo: home_business_section.dart
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
    final businessDataCurrent = businessData;

    return Stack(
      children: [
        // HEADER + espacio extra para overlap visual
        //ROW HEADER
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.32,
          child: HeaderBusinessSection(businessData: businessDataCurrent),
        ),
        //ROW TASK
        Padding(
          padding: const EdgeInsets.only(top: 160),
          child: Column(
            children: [
              TaskListBusinessSection(businessData: businessDataCurrent),
              const SizedBox(height: 20),
            ],
          ),
        )
        , //DATA CHANGE
        Padding(
          padding: const EdgeInsets.only(top: 160),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text("Today's plan", style: theme.textTheme.titleMedium),
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
              Expanded(child: ActivityListBusiness(businessData: businessDataCurrent)),
            ],
          ),
        )
      ],
    );
  }
} 