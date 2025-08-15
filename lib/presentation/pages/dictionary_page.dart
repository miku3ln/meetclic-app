import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic/shared/themes/app_colors.dart';

import '../pages/dictionary_page/search_language_app_bar.dart';
import '../pages/dictionary_page/word_tile.dart';

class DictionaryPage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  /// Cómo obtener la etiqueta visible de cada chip sin usar `dynamic`.
  /// Ej.: (m) => m.name  |  (m) => m.text
  final String Function(MenuTabUpItem item)? labelBuilder;

  const DictionaryPage({
    super.key,
    required this.title,
    required this.itemsStatus,
    this.labelBuilder,
  });

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  // --------- Controllers ---------
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  // --------- Paginación / estado ----------
  final List<WordItem> _items = [];
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  int _page = 1;
  final int _pageSize = 10;

  // --------- Filtros ----------
  String _language = 'ES';
  int _selectedCategory = 0;
  String _query = '';

  // --------- Scroll helpers ----------
  static const double _infiniteThreshold = 250.0; // px antes del fondo
  double _lastPixels = 0.0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _attachScrollHandlers(); // 👈 toda la lógica de scroll queda aquí
    Future.microtask(_loadInitial); // carga inicial
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _safeLabel(MenuTabUpItem item) => item.toString();

  // =========================================================
  // ===============   SCROLL: HANDLERS LIMPIOS   ============
  // =========================================================

  void _attachScrollHandlers() {
    // Listener de posición (progreso, dirección, near-bottom, etc.)
    _scrollController.addListener(_onScroll);

    // Inicio/fin de arrastre (drag)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.position.isScrollingNotifier.addListener(
        _onScrollStateChange,
      );
    });
  }

  void _onScroll() {
    final position = _scrollController.position;

    // 1) Near-bottom -> infinite scroll
    final nearBottom =
        position.pixels >= (position.maxScrollExtent - _infiniteThreshold);
    if (nearBottom && !_isLoadingMore && _hasMore && !_isInitialLoading) {
      _loadMore();
    }

    // 2) Dirección (opcional para futuras animaciones)
    final goingDown = position.pixels > _lastPixels;
    final goingUp = position.pixels < _lastPixels;
    // debugPrint(goingDown ? '⬇️ Bajando' : (goingUp ? '⬆️ Subiendo' : '—'));

    // 3) Inicio / Fin (opcional)
    final atTop = position.pixels <= position.minScrollExtent;
    final atBottom = position.pixels >= position.maxScrollExtent;
    // if (atTop) debugPrint('🏁 Top');
    // if (atBottom) debugPrint('🏁 Bottom');

    // 4) Overscroll (opcional)
    final over = position.outOfRange;
    // if (over) debugPrint('⚠️ Overscroll');

    // 5) Porcentaje (opcional)
    final max = position.maxScrollExtent <= 0 ? 1.0 : position.maxScrollExtent;
    final percent = (position.pixels / max).clamp(0.0, 1.0);
    // debugPrint('📊 ${(percent * 100).toStringAsFixed(1)}%');

    _lastPixels = position.pixels;
  }

  void _onScrollStateChange() {
    final isDragging = _scrollController.position.isScrollingNotifier.value;
    // if (isDragging) {
    //   debugPrint('👆 Usuario está arrastrando');
    // } else {
    //   debugPrint('🛑 Usuario dejó de arrastrar');
    // }
  }

  // =========================================================
  // ===============        DATA LAYER (demo)      ===========
  // =========================================================

  /// Método asíncrono para obtener registros (reemplaza con tu repo/servicio).
  Future<List<WordItem>> _getDataRegisters({
    required int page,
    required int pageSize,
    required String language,
    required String query,
    int? categoryIndex,
  }) async {
    // Simula red
    await Future.delayed(const Duration(milliseconds: 900));

    // Demo: genera datos de ejemplo
    final start = (page - 1) * pageSize;
    final generated = List.generate(pageSize, (i) {
      final idx = start + i + 1;
      return WordItem(
        image: 'https://picsum.photos/seed/${language}_${query}_$idx/200/200',
        title: 'Word $idx',
        subtitle: '/wɜːd $idx/',
        description:
            'Description for word $idx in $language. Category=$categoryIndex, q="$query".',
      );
    });

    // Filtro mock por query
    final filtered = query.isEmpty
        ? generated
        : generated
              .where((w) => w.title.toLowerCase().contains(query.toLowerCase()))
              .toList();

    // Demo: simular fin de datos después de la 5ta página
    if (page >= 5) {
      return filtered.take(pageSize ~/ 2).toList();
    }
    return filtered;
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _isLoadingMore = false;
      _hasMore = true;
      _page = 1;
      _items.clear();
    });

    final data = await _getDataRegisters(
      page: _page,
      pageSize: _pageSize,
      language: _language,
      query: _query,
      categoryIndex: _selectedCategory,
    );

    if (!mounted) return;
    setState(() {
      _items.addAll(data);
      _hasMore = data.length == _pageSize;
      _isInitialLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _page + 1;

    final data = await _getDataRegisters(
      page: nextPage,
      pageSize: _pageSize,
      language: _language,
      query: _query,
      categoryIndex: _selectedCategory,
    );

    if (!mounted) return;
    setState(() {
      _page = nextPage;
      _items.addAll(data);
      _hasMore = data.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  // =========================================================
  // ===============            UI                ============
  // =========================================================

  // búsqueda con debounce
  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      _query = q.trim();
      _loadInitial();
    });
  }

  void _onLanguageChanged(String lang) {
    setState(() => _language = lang);
    _loadInitial();
  }

  void _onFilterTap() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 240,
        child: Center(
          child: Text('Aquí tus filtros (lang: $_language, q: $_query)'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SearchLanguageAppBar(
        controller: _searchCtrl,
        onChanged: _onSearchChanged, // búsqueda en vivo
        onFilterTap: _onFilterTap, // botón filtros
        language: _language,
        onLanguageChanged: _onLanguageChanged,
      ),
      body: SafeArea(
        child: _isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // --------- CARRUSEL DE CATEGORÍAS ---------
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(widget.itemsStatus.length, (i) {
                          final item = widget.itemsStatus[i];
                          final label =
                              widget.labelBuilder?.call(item) ??
                              _safeLabel(item);
                          final selected = _selectedCategory == i;

                          return Padding(
                            padding: EdgeInsets.only(
                              right: i == widget.itemsStatus.length - 1 ? 0 : 8,
                            ),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.category_outlined, size: 16),
                                  const SizedBox(width: 6),
                                  Text(label),
                                ],
                              ),
                              selected: selected,
                              onSelected: (_) {
                                setState(() => _selectedCategory = i);
                                _loadInitial(); // recarga por categoría
                              },
                              selectedColor: AppColors.azulClic.withOpacity(
                                .12,
                              ),
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppColors.azulClic
                                    : AppColors.grisOscuro,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? AppColors.azulClic
                                    : AppColors.moradoSuave.withOpacity(.2),
                              ),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --------- HEADER LISTA ---------
                    Row(
                      children: [
                        Text(
                          'New Words',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.grisOscuro,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // --------- LISTA ---------
                    ListView.separated(
                      itemCount: _items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final w = _items[index];
                        return WordTile(
                          item: w,
                          onPlay: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Reproducir: ${w.title}')),
                            );
                          },
                        );
                      },
                    ),

                    if (_isLoadingMore) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (!_hasMore && _items.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'No more results',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
