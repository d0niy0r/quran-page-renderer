import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../data/models/verse_model.dart';
import '../../data/models/word_model.dart';
import '../../data/services/font_service.dart';

/// Sahifani QPC V4 Tajweed font bilan render qiladi.
/// Har bir qator \n bilan ajratilgan, TextAlign.justify qatorlarni tekislaydi.
/// Font o'zida tajweed ranglar, kashida/cho'zilish bor.
class QuranPageText extends StatelessWidget {
  final Map<int, List<WordModel>> lines;
  final int pageNumber;
  final VerseModel? Function(String verseKey)? verseLookup;
  final void Function(VerseModel verse)? onVerseTap;

  const QuranPageText({
    super.key,
    required this.lines,
    required this.pageNumber,
    this.verseLookup,
    this.onVerseTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontLoaded = FontService.isLoaded(pageNumber);
    final fontFamily = fontLoaded
        ? FontService.fontFamilyForPage(pageNumber)
        : 'UthmanicHafs';

    final lineNumbers = lines.keys.toList()..sort();
    final allSpans = <InlineSpan>[];

    for (int li = 0; li < lineNumbers.length; li++) {
      final lineNum = lineNumbers[li];
      final words = lines[lineNum] ?? [];

      for (int wi = 0; wi < words.length; wi++) {
        final word = words[wi];

        // QPC glyph font yuklangan bo'lsa code_v2 ishlatamiz
        final displayText =
            fontLoaded && word.codeV2.isNotEmpty ? word.codeV2 : word.text;

        allSpans.add(TextSpan(
          text: displayText,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontLoaded ? 28 : 22,
            color: fontLoaded ? null : const Color(0xFF212121),
            height: 1.8,
          ),
          recognizer: _recognizerFor(word.verseKey),
        ));

        // So'zlar orasiga bo'shliq (faqat QPC fontda kerak emas — glyphlar o'zi joylashadi)
        if (!fontLoaded && wi < words.length - 1) {
          allSpans.add(const TextSpan(text: ' '));
        }
      }

      // Qatorlar orasiga yangi qator
      if (li < lineNumbers.length - 1) {
        allSpans.add(const TextSpan(text: '\n'));
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(children: allSpans),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  GestureRecognizer? _recognizerFor(String verseKey) {
    if (onVerseTap == null || verseLookup == null) return null;
    final verse = verseLookup!(verseKey);
    if (verse == null) return null;
    return TapGestureRecognizer()..onTap = () => onVerseTap!(verse);
  }
}