import 'package:flutter/material.dart';
import '../../domain/entities/business.dart';

class BusinessDetailPage extends StatefulWidget {
  final Business business;
  const BusinessDetailPage({super.key, required this.business});

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _HomeSection(),
    _ShopSection(),
    _NewsSection(),
    _GamificationSection(),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _pages[_selectedIndex],
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: theme.colorScheme.onPrimary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(icon: Icons.home, index: 0),
              _buildNavIcon(icon: Icons.shopping_bag, index: 1),
              const SizedBox(width: 40), // espacio para botón central
              _buildNavIcon(icon: Icons.newspaper, index: 2),
              _buildNavIcon(icon: Icons.emoji_events, index: 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add_business),
        onPressed: () {
          // Lógica para agregar empresa como parte mía
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavIcon({required IconData icon, required int index}) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.grey),
      onPressed: () => _onNavTap(index),
    );
  }
}
class _HomeSection extends StatelessWidget {
  const _HomeSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
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
              Text('HI! Stone', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('There are 3 important things...', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 20),
              Row(
                children: [
                  _TaskCard(
                    icon: Icons.medical_services,
                    title: 'Take the medicine',
                    subtitle: '3 times a day',
                    percent: 0.33,
                    accentColor: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _TaskCard(
                    icon: Icons.music_note,
                    title: 'Music lesson',
                    subtitle: 'The sixth string',
                    percent: 0.0,
                    accentColor: Colors.green,
                  ),
                ],
              )
            ],
          ),
        ),
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
        const Expanded(
          child: _ActivityList(),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double percent;
  final Color accentColor;

  const _TaskCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percent,
              color: accentColor,
              backgroundColor: accentColor.withOpacity(0.2),
              minHeight: 4,
            )
          ],
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: const [
        _ActivityItem(
          icon: Icons.local_laundry_service,
          title: 'Wash yesterday\'s clothes',
          subtitle: 'The whole life should wash',
          color: Colors.orangeAccent,
          time: 'Just now',
        ),
        _ActivityItem(
          icon: Icons.book,
          title: 'Read a design journal',
          subtitle: 'Be the best designer',
          color: Colors.blueAccent,
          time: '3 h later',
        ),
        _ActivityItem(
          icon: Icons.attach_money,
          title: 'Go to the bank',
          subtitle: 'Take out the design fee',
          color: Colors.green,
          time: '6 h later',
        ),
        _ActivityItem(
          icon: Icons.palette,
          title: 'Post a work on dribbble',
          subtitle: 'Hope to be recognized',
          color: Colors.pinkAccent,
          time: '7 h later',
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Text(time, style: const TextStyle(color: Colors.grey)),
    );
  }
}
class _ShopSection extends StatelessWidget {
  const _ShopSection();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Tienda", style: TextStyle(fontSize: 20)));
  }
}

class _NewsSection extends StatelessWidget {
  const _NewsSection();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Noticias", style: TextStyle(fontSize: 20)));
  }
}

class _GamificationSection extends StatelessWidget {
  const _GamificationSection();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Gamificación", style: TextStyle(fontSize: 20)));
  }
}
