import 'package:flutter/material.dart';
import '../../domain/entities/business.dart';

class BusinessDetailPage extends StatelessWidget {
  final Business business;

  const BusinessDetailPage({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, size),
            const SizedBox(height: 60),
            _buildInfoSection(theme),
            const SizedBox(height: 20),
            _buildContactSection(),
            const SizedBox(height: 20),
            _buildSocialIcons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Cabecera con fondo curvo, imagen remota y avatar
  Widget _buildHeader(BuildContext context, Size size) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        ClipPath(
          clipper: CurvedHeaderClipper(),
          child: Container(
            height: size.height * 0.28,
            color: theme.colorScheme.primary,
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              business.imageBackground, // <- imagen desde URL
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.surface,
          child: ClipOval(
            child: Image.network(
              business.imageLogo,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
          ),
        ),
      ],
    );
  }

  // Nombre, descripción y puntos
  Widget _buildInfoSection(ThemeData theme) {
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

  // Contacto simulado (puedes pasar estos datos desde `Business` si gustas)
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

  // Íconos sociales
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
}

// Reusable: Widget para mostrar ítems de contacto
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
      ),
    );
  }
}

// Reusable: Widget para íconos sociales
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

// ClipPath personalizado para el fondo
class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 50)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
