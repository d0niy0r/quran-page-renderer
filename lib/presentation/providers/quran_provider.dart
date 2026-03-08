import 'package:flutter/material.dart';
import '../../data/models/chapter_model.dart';
import '../../data/repositories/quran_repository.dart';

enum LoadingState { idle, loading, loaded, error }

class QuranProvider extends ChangeNotifier {
  final QuranRepository _repository;

  QuranProvider({QuranRepository? repository})
      : _repository = repository ?? QuranRepository();

  List<ChapterModel> _chapters = [];
  List<ChapterModel> _filteredChapters = [];
  LoadingState _chaptersState = LoadingState.idle;
  String _error = '';
  String _searchQuery = '';

  List<ChapterModel> get chapters =>
      _searchQuery.isEmpty ? _chapters : _filteredChapters;
  LoadingState get chaptersState => _chaptersState;
  String get error => _error;

  Future<void> loadChapters() async {
    if (_chaptersState == LoadingState.loaded) return;

    _chaptersState = LoadingState.loading;
    notifyListeners();

    try {
      _chapters = await _repository.getChapters();
      _chaptersState = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _chaptersState = LoadingState.error;
    }

    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredChapters = [];
    } else {
      final q = query.toLowerCase();
      _filteredChapters = _chapters.where((c) {
        return c.nameSimple.toLowerCase().contains(q) ||
            c.nameArabic.contains(query) ||
            c.translatedName.toLowerCase().contains(q) ||
            c.id.toString() == query;
      }).toList();
    }
    notifyListeners();
  }
}