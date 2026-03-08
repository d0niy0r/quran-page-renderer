import 'package:flutter/material.dart';
import '../../core/constants/tajweed_colors.dart';
import '../../data/models/word_model.dart';
import '../../utils/tajweed_parser.dart';

class QuranLineWidget extends StatelessWidget {
  final List<WordModel> words;
  final bool isLastLine;
  final void Function(WordModel word)? onWordTap;
  // verseKey → tajweed spanlar
  final Map<String, List<TajweedSpan>> tajweedByVerse;

  const QuranLineWidget({
    super.key,
    required this.words,
    this.isLastLine = false,
    this.onWordTap,
    required this.tajweedByVerse,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: words
              .map((word) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _buildWord(word),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildWord(WordModel word) {
    final isEndMarker = word.charTypeName == 'end';

    // Oyat belgi raqami — yashil rang
    if (isEndMarker) {
      return GestureDetector(
        onTap: onWordTap != null ? () => onWordTap!(word) : null,
        child: Text(
          word.text,
          style: const TextStyle(
            fontFamily: 'UthmanicHafs',
            fontSize: 18,
            color: Color(0xFF1B5E20),
            height: 1.9,
          ),
          textDirection: TextDirection.rtl,
        ),
      );
    }

    // Tajweed spanlaridan ushbu so'zga tegishli qismlarni topamiz
    final spans = _findTajweedSpansForWord(word);

    if (spans != null && spans.isNotEmpty) {
      return GestureDetector(
        onTap: onWordTap != null ? () => onWordTap!(word) : null,
        child: RichText(
          textDirection: TextDirection.rtl,
          text: TextSpan(
            children: spans.map((span) {
              return TextSpan(
                text: span.text,
                style: TextStyle(
                  fontFamily: 'UthmanicHafs',
                  fontSize: 22,
                  color: TajweedColors.getColor(span.cssClass),
                  height: 1.9,
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    // Fallback: oddiy qora rang
    return GestureDetector(
      onTap: onWordTap != null ? () => onWordTap!(word) : null,
      child: Text(
        word.text,
        style: const TextStyle(
          fontFamily: 'UthmanicHafs',
          fontSize: 22,
          color: Color(0xFF212121),
          height: 1.9,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  /// So'z matnini tajweed spanlaridan topish
  /// Tajweed matn butun oyat uchun berilgan, shuning uchun
  /// so'z matnini tajweed matni ichidan qidiramiz
  List<TajweedSpan>? _findTajweedSpansForWord(WordModel word) {
    final verseSpans = tajweedByVerse[word.verseKey];
    if (verseSpans == null || verseSpans.isEmpty) return null;

    // So'z matnidagi harflarni (diacritics olib tashlangan) qidiramiz
    final wordClean = _removeNonLetters(word.text);
    if (wordClean.isEmpty) return null;

    // Tajweed spanlar ichidan bu so'zga mos keladiganlarini topamiz
    // Tajweed matnini birlashtirgan holda position tracker bilan izlaymiz
    final result = <TajweedSpan>[];

    // So'z position dan foydalanib, tajweed ichidan shu so'z joylashgan qismni topamiz
    // Oddiy usul: barcha span matnlarini birlashtirish va so'z pozitsiyasini hisoblash
    final fullText = StringBuffer();
    for (final span in verseSpans) {
      fullText.write(span.text);
    }
    final fullStr = fullText.toString();

    // So'z matnini tajweed matni ichidan topamiz (harflar bo'yicha)
    final wordStart = _findWordPosition(fullStr, wordClean, word.position);
    if (wordStart == -1) return null;

    final wordEnd = wordStart + _getMatchLength(fullStr, wordStart, wordClean);

    // Endi spans ichidan shu diapazon uchun tegishli spanlarni ajratamiz
    int charOffset = 0;
    for (final span in verseSpans) {
      final spanStart = charOffset;
      final spanEnd = charOffset + span.text.length;

      // Bu span so'z diapazoni bilan kesishganmi?
      if (spanEnd > wordStart && spanStart < wordEnd) {
        final overlapStart = spanStart < wordStart ? wordStart - spanStart : 0;
        final overlapEnd = spanEnd > wordEnd ? span.text.length - (spanEnd - wordEnd) : span.text.length;

        if (overlapStart < overlapEnd && overlapEnd <= span.text.length) {
          result.add(TajweedSpan(
            text: span.text.substring(overlapStart, overlapEnd),
            cssClass: span.cssClass,
          ));
        }
      }

      charOffset = spanEnd;
    }

    return result.isNotEmpty ? result : null;
  }

  /// Arab harflardan boshqa belgilarni olib tashlash (diacritics va boshqalar)
  String _removeNonLetters(String text) {
    // Faqat arab harflarini (U+0620-U+064A, U+0671-U+06FF, tatweel U+0640) qoldirish
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      if ((rune >= 0x0620 && rune <= 0x064A) ||
          (rune >= 0x0671 && rune <= 0x06FF) ||
          rune == 0x0640) {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// So'z pozitsiyasi bo'yicha tajweed matnidagi joyni topish
  int _findWordPosition(String fullText, String wordClean, int wordPosition) {
    // wordPosition = so'z tartibi (1-based)
    // fullText ichidan n-chi arab so'zning boshlanish indeksini topamiz
    int currentWord = 0;
    int i = 0;
    bool inWord = false;

    while (i < fullText.length) {
      final rune = fullText.codeUnitAt(i);
      final isLetter = (rune >= 0x0620 && rune <= 0x064A) ||
          (rune >= 0x0671 && rune <= 0x06FF) ||
          rune == 0x0640 ||
          // Diacritics ham so'zning qismi
          (rune >= 0x064B && rune <= 0x0670) ||
          (rune >= 0x06D6 && rune <= 0x06ED) ||
          // Small high/low marks
          (rune >= 0x0610 && rune <= 0x061A);

      if (isLetter && !inWord) {
        currentWord++;
        inWord = true;
        if (currentWord == wordPosition) {
          return i;
        }
      } else if (!isLetter) {
        inWord = false;
      }
      i++;
    }
    return -1;
  }

  /// So'z boshlanish nuqtasidan qancha belgi tegishli ekanini hisoblash
  int _getMatchLength(String fullText, int start, String wordClean) {
    int matched = 0;
    int i = start;
    while (i < fullText.length && matched < wordClean.length) {
      final rune = fullText.codeUnitAt(i);
      final isBase = (rune >= 0x0620 && rune <= 0x064A) ||
          (rune >= 0x0671 && rune <= 0x06FF) ||
          rune == 0x0640;

      if (isBase) {
        if (rune == wordClean.codeUnitAt(matched)) {
          matched++;
        } else {
          break;
        }
      }
      i++;
    }
    // Diacriticsni ham o'z ichiga olish
    while (i < fullText.length) {
      final rune = fullText.codeUnitAt(i);
      final isDiacritic = (rune >= 0x064B && rune <= 0x0670) ||
          (rune >= 0x06D6 && rune <= 0x06ED) ||
          (rune >= 0x0610 && rune <= 0x061A);
      if (!isDiacritic) break;
      i++;
    }
    return i - start;
  }
}