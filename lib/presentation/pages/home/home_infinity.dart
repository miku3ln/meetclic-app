
import 'package:flutter/material.dart';
import 'dart:math';
class HomeScrollView extends StatefulWidget {
  const HomeScrollView({super.key});

  @override
  State<HomeScrollView> createState() => _HomeScrollViewState();
}

class _HomeScrollViewState extends State<HomeScrollView> {
  final ScrollController _scrollController = ScrollController();
  final List<Widget> _contentWidgets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMoreContent();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _loadMoreContent();
      }
    });
  }

  void _loadMoreContent() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simula red

    List<Widget> newWidgets = List.generate(5, (_) => _generateRandomWidget());
    setState(() {
      _contentWidgets.addAll(newWidgets);
      _isLoading = false;
    });
  }

  Widget _generateRandomWidget() {
    final random = Random();
    final type = random.nextBool();

    if (type) {
      return _ListItem(title: 'Item ${random.nextInt(1000)}');
    } else {
      return const _CarouselSection();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        _contentWidgets.clear();
        _loadMoreContent();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _contentWidgets.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _contentWidgets.length) {
            return _contentWidgets[index];
          } else {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;

  const _ListItem({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.star, color: theme.colorScheme.secondary),
      title: Text(title, style:  TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 18,
      )),
      onTap: () {},
    );
  }
}

class _CarouselSection extends StatelessWidget {
  const _CarouselSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ShoeCarouselWidget(),
    );
  }
}

class ShoeCarouselWidget extends StatelessWidget {
  const ShoeCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> shoes = [
      {
        'title': 'Air Max Plus',
        'image': 'https://assets.adidas.com/images/w_1880,f_auto,q_auto/dc9953df47e443a79524adc50177d71e_9366/GY5427_01_standard.jpg',
      },
      {
        'title': 'Nike Jordan',
        'image': 'https://m.media-amazon.com/images/I/71UpvHftX6L._AC_SL1500_.jpg',
      },
      {
        'title': 'Adidas Ultra',
        'image': 'https://assets.adidas.com/images/w_1880,f_auto,q_auto/4a46e180c40643c8b436af9c017a4615_9366/ID2054_01_standard.jpg',
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shoes.length,
            itemBuilder: (context, index) {
              final shoe = shoes[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        shoe['image']!,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 80),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(shoe['title']!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _CategoryItem(icon: Icons.percent, label: 'Ofertas'),
            _CategoryItem(icon: Icons.directions_walk, label: 'Sneakers'),
            _CategoryItem(icon: Icons.beach_access, label: 'Sandalias'),
            _CategoryItem(icon: Icons.shopping_bag, label: 'Crocs'),
          ],
        ),
      ],
    );
  }
}


class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}