// pages/dictionary_page/services/mock_dictionary_service.dart
import 'dart:async';

import '../models/word_item.dart';
import 'dictionary_service.dart';

class MockDictionaryService implements DictionaryService {
  @override
  Future<List<WordItem>> getDataRegisters({
    required int page,
    required int pageSize,
    required String language,
    required String query,
    int? categoryIndex,
  }) async {
    // Simula red
    await Future.delayed(const Duration(milliseconds: 900));

    final start = (page - 1) * pageSize;
    final generated = List<WordItem>.generate(pageSize, (i) {
      final idx = start + i + 1;
      return WordItem(
        image: 'https://picsum.photos/seed/${language}_${query}_$idx/200/200',
        title: 'Word $idx',
        subtitle: '/wɜːd $idx/',
        description:
            'Description for word $idx in $language. Category=$categoryIndex, q="$query".',
      );
    });

    final filtered = query.isEmpty
        ? generated
        : generated
              .where((w) => w.title.toLowerCase().contains(query.toLowerCase()))
              .toList();

    // Simula fin de páginas (a partir de la 5 no hay tantos resultados)
    return page >= 5 ? filtered.take(pageSize ~/ 2).toList() : filtered;
  }
}
