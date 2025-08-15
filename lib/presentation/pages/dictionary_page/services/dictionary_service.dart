// pages/dictionary_page/services/dictionary_service.dart
import '../models/word_item.dart';

abstract class DictionaryService {
  Future<List<WordItem>> getDataRegisters({
    required int page,
    required int pageSize,
    required String language,
    required String query,
    int? categoryIndex,
  });
}
