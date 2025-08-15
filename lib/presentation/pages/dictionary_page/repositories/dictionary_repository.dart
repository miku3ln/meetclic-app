// pages/dictionary_page/repositories/dictionary_repository.dart
import '../models/word_item.dart';
import '../services/dictionary_service.dart';

class DictionaryRepository {
  final DictionaryService service;
  const DictionaryRepository(this.service);

  Future<List<WordItem>> getPage({
    required int page,
    required int pageSize,
    required String language,
    required String query,
    int? categoryIndex,
  }) {
    return service.getDataRegisters(
      page: page,
      pageSize: pageSize,
      language: language,
      query: query,
      categoryIndex: categoryIndex,
    );
  }
}
