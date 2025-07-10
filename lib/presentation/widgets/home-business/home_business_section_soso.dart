// Archivo: home_business_section.dart
import 'package:flutter/material.dart';
import 'header_business_section.dart';
import 'task_list_business_section.dart';
import 'activity_list_business_section.dart';
import '../../../domain/entities/business.dart';

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(leading: Icon(icon), title: Text(text)),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white24,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class HomeBusinessSection extends StatelessWidget {
  final BusinessData businessData;

  const HomeBusinessSection({super.key, required this.businessData});

  @override
  Widget build(BuildContext context) {
    Widget _buildContactSection() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: const [
            _InfoTile(icon: Icons.phone, text: '+593 99 999 9999'),
            _InfoTile(icon: Icons.email, text: 'info@empresa.com'),
            _InfoTile(icon: Icons.public, text: 'www.empresa.com'),
            _InfoTile(icon: Icons.location_on, text: 'Otavalo, Imbabura'),
          ],
        ),
      );
    }

    Widget _buildSocialIcons() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _SocialIcon(icon: Icons.facebook),
          _SocialIcon(icon: Icons.alternate_email),
          _SocialIcon(icon: Icons.business),
        ],
      );
    }
    Widget _buildInfoSection(ThemeData theme) {
      final business=businessData.business;
      return Column(
        children: [
          Text(
            business.name,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            business.description,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '+${business.points} puntos',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }
    final theme = Theme.of(context);
    final businessDataCurrent = businessData;
    final paddingContainer = MediaQuery.of(context).size.height * 0.38;
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
        ), //DATA CHANGE

        Container(
          padding: EdgeInsets.only(top: paddingContainer),
          child: Column(
            children: [
              _buildContactSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "Actividades de la Empresa:",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme
                            .colorScheme
                            .primary, // se puede personalizar desde el Theme
                      ),
                    ),
                    const Spacer(),
                    /* const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFFE0FFF2),
                      child: Text('75%', style: TextStyle(color: Colors.teal, fontSize: 12)),
                    ),*/

                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ActivityListBusiness(businessData: businessDataCurrent)),

            ],
          ),
        ),
      ],
    );
  }
}
