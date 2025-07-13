import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meetclic/presentation/widgets/home/carousel_section.dart';
import 'package:meetclic/presentation/widgets/home/news_item.dart';
import 'package:meetclic/presentation/widgets/home/promo_banner.dart';

class HomeScrollView extends StatefulWidget {
  const HomeScrollView({super.key});

  @override
  State<HomeScrollView> createState() => _HomeScrollViewState();
}

class _HomeScrollViewState extends State<HomeScrollView> {
  final ScrollController _scrollController = ScrollController();
  final List<Widget> _widgets = [];
  bool _isLoading = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureEnoughContent();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading) {
      _loadMoreContent();
    }
  }

  Future<void> _ensureEnoughContent() async {
    do {
      await _loadMoreContent();
      await Future.delayed(const Duration(milliseconds: 300));
    } while (_scrollController.position.maxScrollExtent <
        MediaQuery.of(context).size.height &&
        !_isLoading);
  }

  Future<void> _loadMoreContent() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final data = _fetchFakeApi(_page++);
    final newWidgets = data.map(_buildWidgetFromData).toList();

    setState(() {
      _widgets.addAll(newWidgets);
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _fetchFakeApi(int page) {
    final List<String> types = ['news', 'carousel', 'promo'];
    final random = Random();
    final int count = random.nextInt(4) + 5; // entre 5 y 8 elementos

    return List.generate(count, (index) {
      final type = types[random.nextInt(types.length)];
      return {
        'type': type,
        'title': '$type block #${(page - 1) * 10 + index + 1}',
        'data': {'content': 'Contenido simulado de tipo $type'}
      };
    });
  }

  Widget _buildWidgetFromData(Map<String, dynamic> block) {
    switch (block['type']) {
      case 'news':
        return NewsItem(title: block['title']);
      case 'carousel':
        return const CarouselSection();
      case 'promo':
        return PromoBanner(text: block['title']);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _widgets.clear();
      _page = 1;
    });
    await _ensureEnoughContent();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  ..._widgets,
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
