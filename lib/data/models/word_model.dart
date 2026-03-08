class WordModel {
  final int id;
  final String text;
  final String charTypeName;
  final int position;
  final String? translation;
  final int lineNumber;
  final int pageNumber;
  final String verseKey;
  /// QPC V2/V4 glyph kodi — Tarteel font uchun
  final String codeV2;

  WordModel({
    required this.id,
    required this.text,
    required this.charTypeName,
    required this.position,
    this.translation,
    required this.lineNumber,
    required this.pageNumber,
    required this.verseKey,
    required this.codeV2,
  });

  factory WordModel.fromJson(Map<String, dynamic> json, {String verseKey = ''}) {
    return WordModel(
      id: json['id'] ?? 0,
      text: json['text_uthmani'] ?? json['text'] ?? '',
      charTypeName: json['char_type_name'] ?? 'word',
      position: json['position'] ?? 0,
      translation: json['translation']?['text'],
      lineNumber: json['line_number'] ?? 0,
      pageNumber: json['page_number'] ?? 0,
      verseKey: verseKey,
      codeV2: json['code_v2'] ?? '',
    );
  }
}