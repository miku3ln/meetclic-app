// Archivo: home_business_section.dart
import 'package:flutter/material.dart';
import 'header_business_section.dart';
import 'task_list_business_section.dart';
import 'activity_list_business_section.dart';
import '../../../domain/entities/business.dart';
import '../../../shared/utils/util_common.dart'; // ajusta el import según tu estructura

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final String type;

  const _InfoTile({required this.icon, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(leading: Icon(icon), title: Text(text),
        onTap: () =>(
            UtilCommon.handleTap(
              context: context,
              type: type,
              text: text,
            )
        )

        ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const _SocialIcon({required this.icon,required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () => (
            UtilCommon.handleTap(
              context: context,
              type: "web",
              text: url,
            )
        ),
        borderRadius: BorderRadius.circular(22),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white24,
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
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
            _InfoTile(icon: Icons.phone, text: '+593 985339457',type: "whatsapp"),
            _InfoTile(icon: Icons.email, text: 'info@empresa.com',type: "email"),
            _InfoTile(icon: Icons.public, text: 'www.empresa.com',type: "web"),
            _InfoTile(icon: Icons.location_on, text: 'Otavalo, Imbabura',type: ""),
          ],
        ),
      );
    }

    Widget _buildSocialIcons() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _SocialIcon(icon: Icons.facebook,url:"https://www.instagram.com/ideas_bip?igsh=MXR2eWZqbjcwdXF2bw=="),
          _SocialIcon(icon: Icons.camera_alt,url:"https://www.instagram.com/ideas_bip?igsh=MXR2eWZqbjcwdXF2bw=="),
          _SocialIcon(
            icon: Icons.videocam, // temporal para TikTok
            url: 'https://www.tiktok.com/@ideasbip',
          ),
          _SocialIcon(icon: Icons.business,url:"www.meetclic.com"),
        ],
      );
    }
    final theme = Theme.of(context);
    final businessDataCurrent = businessData;
    final paddingContainer = MediaQuery.of(context).size.height * 0.38;
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.32,
          child: HeaderBusinessSection(businessData: businessDataCurrent),
        ),
        // 🔵 Section Header (estático)
        Container(), // Header
        // 🟢 Section Body (scrollable)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Contactanos",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                _buildContactSection(),
                Text(
                  "Redes Sociales",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                _buildSocialIcons(),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
