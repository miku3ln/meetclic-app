import 'dart:async';

import 'package:flutter/material.dart';

import '../models/word_item.dart';
import '../repositories/dictionary_repository.dart';

class DictionaryController extends ChangeNotifier {
  DictionaryController(this._repo);
  final DictionaryRepository _repo;

  // ---------- estado público ----------
  final List<WordItem> items = [];
  bool isInitialLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool isRefreshing = false;
  bool scrollLocked = false;

  // ---------- criterios ----------
  String language = 'KI';
  int selectedCategory = 0;
  String query = '';

  // ---------- paginación ----------
  int _page = 1;
  final int _pageSize = 10;

  // ---------- scroll ----------
  static const double infiniteThreshold = 250.0;
  static const double pullToRefreshDistance = 80.0;
  late final ScrollController scrollController;
  double _lastPixels = 0.0;
  bool _wasScrolling = false;
  bool _armedForTopRefresh = false; // latch

  Timer? _debounce;

  // ===== lifecycle =====
  void attachScrollHandlers(ScrollController controller) {
    scrollController = controller;
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.position.isScrollingNotifier.addListener(
        _onScrollStateChange,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.position.isScrollingNotifier.removeListener(
      _onScrollStateChange,
    );
    super.dispose();
  }

  // ===== acciones UI =====
  void onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      query = q.trim();
      loadInitial();
    });
  }

  void setLanguage(String lang) {
    language = lang;
    loadInitial();
  }

  void setCategory(int index) {
    selectedCategory = index;
    loadInitial();
  }

  void lockScroll(bool v) {
    if (scrollLocked == v) return;
    scrollLocked = v;
    notifyListeners();
  }

  // ===== data =====
  Future<void> loadInitial() async {
    isInitialLoading = true;
    _resetPagination();
    notifyListeners();
    int entityManagerId = language == "KI" ? 1 : 2;
    final dataManager = await _repo.getDataDictionaryByLanguage(
      current: _page,
      rowCount: _pageSize,
      entity_manager_id: entityManagerId,
      searchPhrase: query,
      categoryIndex: selectedCategory,
    );
    final dataResult = dataManager.data;
    List<WordItem> data = [];

    items.addAll(data);
    hasMore = data.length == _pageSize;
    isInitialLoading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    isRefreshing = true;
    _resetPagination();
    notifyListeners();
    int entityManagerId = language == "EN" ? 1 : 2;

    final dataManager = await _repo.getDataDictionaryByLanguage(
      current: 1,
      rowCount: _pageSize,
      entity_manager_id: entityManagerId,
      searchPhrase: query,
      categoryIndex: selectedCategory,
    );
    final dataResult = dataManager.data;
    List<WordItem> data = [];
    items.addAll(data);
    hasMore = data.length == _pageSize;
    _page = 1;
    isRefreshing = false;
    lockScroll(false);
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || scrollLocked) return;

    isLoadingMore = true;
    notifyListeners();
    int entityManagerId = language == "EN" ? 1 : 2;

    final nextPage = _page + 1;
    final dataManager = await _repo.getDataDictionaryByLanguage(
      current: nextPage,
      rowCount: _pageSize,
      entity_manager_id: entityManagerId,
      searchPhrase: query,
      categoryIndex: selectedCategory,
    );
    final dataResult = dataManager.data;

    List<WordItem> data = [];
    _page = nextPage;
    items.addAll(data);
    hasMore = data.length == _pageSize;
    isLoadingMore = false;
    notifyListeners();
  }

  void _resetPagination() {
    isLoadingMore = false;
    hasMore = true;
    _page = 1;
    items.clear();
  }

  // ===== scroll handlers =====
  void _onScroll() {
    if (scrollLocked) return;
    final pos = scrollController.position;

    // Near-bottom → more
    final nearBottom = pos.pixels >= (pos.maxScrollExtent - infiniteThreshold);
    if (nearBottom && !isLoadingMore && hasMore && !isInitialLoading) {
      loadMore();
    }

    // Latch de pull-to-refresh
    if (pos.pixels < pos.minScrollExtent - pullToRefreshDistance) {
      _armedForTopRefresh = true;
    }

    // Desarmar SOLO si el usuario se aleja del top (no por rebote)
    final goingDown = pos.pixels > _lastPixels;
    if (goingDown && pos.pixels >= pos.minScrollExtent + 1) {
      _armedForTopRefresh = false;
    }

    _lastPixels = pos.pixels;
  }

  void _onScrollStateChange() {
    final pos = scrollController.position;
    final isScrolling = pos.isScrollingNotifier.value;

    if (!isScrolling && _wasScrolling) {
      final atTop = pos.pixels <= pos.minScrollExtent + 0.5;
      if (atTop && _armedForTopRefresh && !isRefreshing) {
        _armedForTopRefresh = false;
        lockScroll(true);
        if (pos.pixels < pos.minScrollExtent + 0.5) {
          scrollController.jumpTo(pos.minScrollExtent);
        }
        // dispara reload sin bloquear el hilo
        unawaited(reload());
      }
    }
    _wasScrolling = isScrolling;
  }
}
