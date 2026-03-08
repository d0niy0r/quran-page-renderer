import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// QPC V4 Tajweed fontlarni sahifa bo'yicha yuklaydi va registratsiya qiladi
class FontService {
  static const String _cdnBase =
      'https://static-cdn.tarteel.ai/qul/fonts/quran_fonts/v4-tajweed/ttf';

  static final Set<int> _loadedPages = {};
  static final Map<int, Future<void>> _loadingFutures = {};

  /// Font family nomi (pageNumber bo'yicha)
  static String fontFamilyForPage(int pageNumber) => 'QPC_V4_P$pageNumber';

  /// Sahifa fontini yuklash va ro'yxatdan o'tkazish
  static Future<void> loadPageFont(int pageNumber) async {
    if (_loadedPages.contains(pageNumber)) return;

    // Agar allaqachon yuklanayotgan bo'lsa, kutamiz
    if (_loadingFutures.containsKey(pageNumber)) {
      return _loadingFutures[pageNumber];
    }

    _loadingFutures[pageNumber] = _doLoad(pageNumber);
    await _loadingFutures[pageNumber];
    _loadingFutures.remove(pageNumber);
  }

  static Future<void> _doLoad(int pageNumber) async {
    try {
      final url = '$_cdnBase/p$pageNumber.ttf';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final fontLoader = FontLoader(fontFamilyForPage(pageNumber));
        fontLoader.addFont(
          Future.value(ByteData.view(response.bodyBytes.buffer)),
        );
        await fontLoader.load();
        _loadedPages.add(pageNumber);
      }
    } catch (_) {
      // Font yuklanmasa, fallback font ishlatiladi
    }
  }

  /// Font allaqachon yuklanganmi?
  static bool isLoaded(int pageNumber) => _loadedPages.contains(pageNumber);
}