import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/verse_model.dart';
import '../models/chapter_model.dart';
import '../../core/constants/api_constants.dart';

class QuranApiService {
  static const Duration _timeout = Duration(seconds: 30);

  Future<List<ChapterModel>> getChapters() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chaptersEndpoint}?language=en');

    try {
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final chaptersJson = data['chapters'] as List<dynamic>;
        return chaptersJson
            .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load chapters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<VerseModel>> getVersesByChapter(
    int chapterNumber, {
    int page = 1,
    int perPage = 50,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.versesEndpoint}/$chapterNumber'
      '?language=en'
      '&words=true'
      '&word_fields=text_uthmani,char_type_name,line_number,page_number,code_v2,v2_page'
      '&translations=131'
      '&per_page=$perPage'
      '&page=$page',
    );

    try {
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final versesJson = data['verses'] as List<dynamic>;
        return versesJson
            .map((v) => VerseModel.fromJson(v as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load verses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Tajweed rang-barang matnni olish (HTML teglar bilan)
  /// verse_key → tajweed HTML matn
  Future<Map<String, String>> getTajweedByChapter(int chapterNumber) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.tajweedEndpoint}'
      '?chapter_number=$chapterNumber',
    );

    try {
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final versesJson = data['verses'] as List<dynamic>;

        final Map<String, String> result = {};
        for (final v in versesJson) {
          final key = v['verse_key'] as String? ?? '';
          final text = v['text_uthmani_tajweed'] as String? ?? '';
          if (key.isNotEmpty) {
            result[key] = text;
          }
        }
        return result;
      } else {
        throw Exception('Failed to load tajweed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}