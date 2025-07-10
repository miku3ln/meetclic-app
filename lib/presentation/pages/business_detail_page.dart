import 'package:flutter/material.dart';
import '../../domain/entities/business.dart';
import '../widgets/home-business/home_business_section.dart';
import '../widgets/home-business/shop_business_section.dart';
import '../widgets/home-business/news_business_section.dart';
import '../widgets/home-business/gamification_business_section.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BusinessDetailPage extends StatefulWidget {
  final Business business;

  const BusinessDetailPage({super.key, required this.business});

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}
class _BusinessDetailPageState extends State<BusinessDetailPage> {
  int _selectedIndex = 0;
  late final BusinessData businessData;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    businessData = BusinessData(business: widget.business);
    _pages = [
      HomeBusinessSection(businessData: businessData),
      const ShopBusinessSection(),
      const NewsBusinessSection(),
      const GamificationBusinessSection(),
    ];
  }

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
          Fluttertoast.showToast(
            msg: "Empresa agregada a tu lista 💼",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavIcon({required IconData icon, required int index}) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.secondary
            : theme.colorScheme.onPrimary,
      ),
      onPressed: () => _onNavTap(index),
    );
  }
}


