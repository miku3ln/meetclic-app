// Archivo: home_business_section.dart
import 'package:flutter/material.dart';
import 'header_business_section.dart';
import '../../../domain/entities/business.dart';
import '../../../shared/utils/util_common.dart'; // ajusta el import según tu estructura
import 'package:meetclic/shared/localization/app_localizations.dart';

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final String type;

  const _InfoTile({required this.icon, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(leading: Icon(icon), title: Text(text,style:TextStyle(fontSize:  theme.textTheme.labelLarge?.fontSize,height: 4)),
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
   final double heightCurrent=280;// MediaQuery.of(context).size.height * 0.32;
    final appLocalizations = AppLocalizations.of(context);

    return Column(
      children: [
        SizedBox(
          height: heightCurrent,
          child: HeaderBusinessSection(businessData: businessDataCurrent,heightTotal: heightCurrent),
        ),
        // 🔵 Section Header (estático)
        Container(), // Header
        // 🟢 Section Body (scrollable)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(

    appLocalizations.translate('aboutUsDataTitle.contact'),
                  style:TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: theme.textTheme.titleLarge?.fontSize,
                  ),
                ),
                _buildContactSection(),
                Text(
                  appLocalizations.translate('aboutUsDataTitle.socials'),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: theme.textTheme.titleLarge?.fontSize,
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
