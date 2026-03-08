import '../models/verse_model.dart';
import '../models/chapter_model.dart';
import '../services/api_service.dart';

class QuranRepository {
  final QuranApiService _apiService;

  QuranRepository({QuranApiService? apiService})
      : _apiService = apiService ?? QuranApiService();

  Future<List<ChapterModel>> getChapters() => _apiService.getChapters();

  Future<List<VerseModel>> getVersesByChapter(
    int chapterNumber, {
    int page = 1,
    int perPage = 50,
  }) =>
      _apiService.getVersesByChapter(
        chapterNumber,
        page: page,
        perPage: perPage,
      );

  Future<Map<String, String>> getTajweedByChapter(int chapterNumber) =>
      _apiService.getTajweedByChapter(chapterNumber);
}