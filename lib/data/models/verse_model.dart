import 'word_model.dart';

class VerseModel {
  final int id;
  final int verseNumber;
  final String verseKey;
  final String textUthmani;
  final List<WordModel> words;
  final String? translationText;
  final int pageNumber;

  VerseModel({
    required this.id,
    required this.verseNumber,
    required this.verseKey,
    required this.textUthmani,
    required this.words,
    this.translationText,
    required this.pageNumber,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    final key = json['verse_key'] as String? ?? '';
    final wordsJson = json['words'] as List<dynamic>? ?? [];
    final words = wordsJson
        .map((w) => WordModel.fromJson(w as Map<String, dynamic>, verseKey: key))
        .toList();

    String? translation;
    if (json['translations'] != null && (json['translations'] as List).isNotEmpty) {
      translation = json['translations'][0]['text'];
    }

    return VerseModel(
      id: json['id'] ?? 0,
      verseNumber: json['verse_number'] ?? 0,
      verseKey: json['verse_key'] ?? '',
      textUthmani: json['text_uthmani'] ?? '',
      words: words,
      translationText: translation,
      pageNumber: json['page_number'] ?? 1,
    );
  }
}