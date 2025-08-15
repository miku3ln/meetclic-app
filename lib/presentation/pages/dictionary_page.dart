import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic/shared/themes/app_colors.dart';

import '../pages/dictionary_page/controllers/dictionary_controller.dart';
import '../pages/dictionary_page/repositories/dictionary_repository.dart';
import '../pages/dictionary_page/search_language_app_bar.dart';
import '../pages/dictionary_page/services/mock_dictionary_service.dart';
import '../pages/dictionary_page/word_tile.dart';

class DictionaryPage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;
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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  late final DictionaryController _vm;

  @override
  void initState() {
    super.initState();
    _vm = DictionaryController(DictionaryRepository(MockDictionaryService()))
      ..addListener(() => setState(() {}));

    _vm.attachScrollHandlers(_scrollController);
    scheduleMicrotask(_vm.loadInitial); // carga inicial
  }

  @override
  void dispose() {
    _vm.dispose();
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _safeLabel(MenuTabUpItem item) => item.toString();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Bouncing + AlwaysScrollable permite overscroll también en Android
    final ScrollPhysics basePhysics = _vm.scrollLocked
        ? const NeverScrollableScrollPhysics()
        : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SearchLanguageAppBar(
        controller: _searchCtrl,
        onChanged: _vm.onSearchChanged,
        onFilterTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => SizedBox(
              height: 240,
              child: Center(
                child: Text(
                  'Aquí tus filtros (lang: ${_vm.language}, q: ${_vm.query})',
                ),
              ),
            ),
          );
        },
        language: _vm.language,
        onLanguageChanged: _vm.setLanguage,
      ),
      body: SafeArea(
        child: _vm.isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : AbsorbPointer(
                absorbing: _vm.scrollLocked,
                child: RefreshIndicator(
                  onRefresh: _vm.reload,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: basePhysics,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // -------------------- CARRUSEL DE CATEGORÍAS --------------------
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: _vm.scrollLocked
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          child: Row(
                            children: List.generate(widget.itemsStatus.length, (
                              i,
                            ) {
                              final item = widget.itemsStatus[i];
                              final label =
                                  widget.labelBuilder?.call(item) ??
                                  _safeLabel(item);
                              final selected = _vm.selectedCategory == i;

                              return Padding(
                                padding: EdgeInsets.only(
                                  right: i == widget.itemsStatus.length - 1
                                      ? 0
                                      : 8,
                                ),
                                child: ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.category_outlined,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(label),
                                    ],
                                  ),
                                  selected: selected,
                                  onSelected: (_) => _vm.setCategory(i),
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

                        // -------------------- HEADER LISTA --------------------
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

                        // -------------------- LISTA DE TARJETAS --------------------
                        ListView.separated(
                          itemCount: _vm.items.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final w = _vm.items[index];
                            return WordTile(
                              item: w,
                              onPlay: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reproducir: ${w.title}'),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        if (_vm.isLoadingMore) ...[
                          const SizedBox(height: 16),
                          const Center(child: CircularProgressIndicator()),
                        ],
                        if (!_vm.hasMore && _vm.items.isNotEmpty) ...[
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
              ),
      ),
    );
  }
}
