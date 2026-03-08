class ChapterModel {
  final int id;
  final String nameArabic;
  final String nameSimple;
  final String nameComplex;
  final String translatedName;
  final int versesCount;
  final int revelationOrder;
  final String revelationPlace;
  final int pages;

  ChapterModel({
    required this.id,
    required this.nameArabic,
    required this.nameSimple,
    required this.nameComplex,
    required this.translatedName,
    required this.versesCount,
    required this.revelationOrder,
    required this.revelationPlace,
    required this.pages,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] ?? 0,
      nameArabic: json['name_arabic'] ?? '',
      nameSimple: json['name_simple'] ?? '',
      nameComplex: json['name_complex'] ?? '',
      translatedName: json['translated_name']?['name'] ?? '',
      versesCount: json['verses_count'] ?? 0,
      revelationOrder: json['revelation_order'] ?? 0,
      revelationPlace: json['revelation_place'] ?? '',
      pages: json['pages']?[0] ?? 1,
    );
  }
}