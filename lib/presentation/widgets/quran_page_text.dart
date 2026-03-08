import 'package:flutter/material.dart';
import '../../data/models/verse_model.dart';
import '../../data/models/word_model.dart';
import '../../data/services/font_service.dart';

/// QPC V4 Tajweed font bilan sahifani render qiladi.
/// Har bir qator alohida FittedBox — hech qachon ikki qatonga o'tmaydi.
class QuranPageText extends StatelessWidget {
  final Map<int, List<WordModel>> lines;
  final int pageNumber;
  final VerseModel? Function(String verseKey)? verseLookup;
  final void Function(VerseModel verse)? onVerseTap;

  const QuranPageText({super.key, required this.lines, required this.pageNumber, this.verseLookup, this.onVerseTap});

  @override
  Widget build(BuildContext context) {
    final fontLoaded = FontService.isLoaded(pageNumber);
    final fontFamily = fontLoaded ? FontService.fontFamilyForPage(pageNumber) : 'UthmanicHafs';

    final lineNumbers = lines.keys.toList()..sort();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: lineNumbers.map((lineNum) {
        final words = lines[lineNum] ?? [];
        return _buildLine(words: words, fontFamily: fontFamily, fontLoaded: fontLoaded);
      }).toList(),
    );
  }

  Widget _buildLine({required List<WordModel> words, required String fontFamily, required bool fontLoaded}) {
    if (words.isEmpty) return const SizedBox.shrink();

    final String lineText;
    if (fontLoaded) {
      // QPC font: code_v2 glyphlari birlashtirilib bitta satrga
      lineText = words.map((w) => w.codeV2).join(' ');
    } else {
      // Fallback: oddiy uthmani matn
      lineText = words.map((w) => w.charTypeName == 'end' ? ' ${w.text} ' : w.text).join(' ');
    }

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => _tapLine(words),
          child: Text(
            lineText,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontLoaded ? 30 : 22,
              color: fontLoaded ? null : const Color(0xFF212121),
              height: 1.6,
              wordSpacing: fontLoaded ? 2.0 : 0,
            ),
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }

  void _tapLine(List<WordModel> words) {
    if (onVerseTap == null || verseLookup == null) return;
    for (final word in words) {
      final verse = verseLookup!(word.verseKey);
      if (verse != null) {
        onVerseTap!(verse);
        return;
      }
    }
  }
}
