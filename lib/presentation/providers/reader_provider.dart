import 'package:flutter/material.dart';
import '../../data/models/verse_model.dart';
import '../../data/models/word_model.dart';
import '../../data/repositories/quran_repository.dart';
import '../../data/services/font_service.dart';
import '../../utils/tajweed_parser.dart';

class ReaderProvider extends ChangeNotifier {
  final QuranRepository _repository;

  ReaderProvider({QuranRepository? repository})
      : _repository = repository ?? QuranRepository();

  // pageNumber → lineNumber → so'zlar
  Map<int, Map<int, List<WordModel>>> _pageLines = {};
  List<int> _pageNumbers = [];

  Map<String, VerseModel> _versesByKey = {};
  Map<String, List<TajweedSpan>> _tajweedByVerse = {};

  bool _isLoading = false;
  String _error = '';
  int _currentPageIndex = 0;
  VerseModel? _selectedVerse;

  // Yuklanayotgan fontlar
  final Set<int> _fontLoadedPages = {};

  Map<int, Map<int, List<WordModel>>> get pageLines => _pageLines;
  List<int> get pageNumbers => _pageNumbers;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get currentPageIndex => _currentPageIndex;
  int get totalPages => _pageNumbers.length;
  VerseModel? get selectedVerse => _selectedVerse;
  Map<String, List<TajweedSpan>> get tajweedByVerse => _tajweedByVerse;

  int get currentQuranPageNumber =>
      _pageNumbers.isNotEmpty ? _pageNumbers[_currentPageIndex] : 0;

  VerseModel? verseByKey(String key) => _versesByKey[key];

  bool isFontLoaded(int pageNumber) => _fontLoadedPages.contains(pageNumber);

  Future<void> loadChapter(int chapterNumber) async {
    _pageLines = {};
    _pageNumbers = [];
    _versesByKey = {};
    _tajweedByVerse = {};
    _fontLoadedPages.clear();
    _error = '';
    _currentPageIndex = 0;
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getVersesByChapter(
          chapterNumber,
          page: 1,
          perPage: 300,
        ),
        _repository.getTajweedByChapter(chapterNumber),
      ]);

      final allVerses = results[0] as List<VerseModel>;
      final tajweedMap = results[1] as Map<String, String>;

      for (final verse in allVerses) {
        _versesByKey[verse.verseKey] = verse;
      }

      for (final entry in tajweedMap.entries) {
        _tajweedByVerse[entry.key] = TajweedParser.parse(entry.value);
      }

      // page → line → words
      final Map<int, Map<int, List<WordModel>>> grouped = {};
      for (final verse in allVerses) {
        for (final word in verse.words) {
          final pageNum =
              word.pageNumber != 0 ? word.pageNumber : verse.pageNumber;
          final lineNum = word.lineNumber;

          grouped
              .putIfAbsent(pageNum, () => {})
              .putIfAbsent(lineNum, () => [])
              .add(word);
        }
      }

      _pageNumbers = grouped.keys.toList()..sort();
      for (final pageNum in _pageNumbers) {
        final lines = grouped[pageNum]!;
        grouped[pageNum] = Map.fromEntries(
          lines.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
        );
      }

      _pageLines = grouped;
      _error = '';

      // Birinchi sahifa fontini yuklash
      if (_pageNumbers.isNotEmpty) {
        await _loadFontForPage(_pageNumbers[0]);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFontForPage(int pageNumber) async {
    if (_fontLoadedPages.contains(pageNumber)) return;

    await FontService.loadPageFont(pageNumber);
    _fontLoadedPages.add(pageNumber);
    notifyListeners();
  }

  void setPageIndex(int index) {
    _currentPageIndex = index;
    notifyListeners();

    // Joriy va qo'shni sahifalar fontlarini yuklash
    final pageNum = _pageNumbers[index];
    _loadFontForPage(pageNum);

    // Keyingi sahifa fontini oldindan yuklash
    if (index + 1 < _pageNumbers.length) {
      _loadFontForPage(_pageNumbers[index + 1]);
    }
  }

  void selectVerse(VerseModel? verse) {
    _selectedVerse = verse;
    notifyListeners();
  }
}