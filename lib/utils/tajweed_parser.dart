/// Tajweed matnini parse qilib, har bir bo'lakni rang bilan belgilash
class TajweedSpan {
  final String text;
  final String? cssClass; // null = oddiy matn

  const TajweedSpan({required this.text, this.cssClass});
}

class TajweedParser {
  /// `<tajweed class=ghunnah>مّ</tajweed>` va `<span class=end>١</span>` teglarini parse qiladi
  static List<TajweedSpan> parse(String html) {
    final spans = <TajweedSpan>[];
    final buffer = StringBuffer();

    int i = 0;
    while (i < html.length) {
      if (html[i] == '<') {
        // Avval bufferdagi oddiy matnni qo'shamiz
        if (buffer.isNotEmpty) {
          spans.add(TajweedSpan(text: buffer.toString()));
          buffer.clear();
        }

        // Tegni topamiz
        final closeAngle = html.indexOf('>', i);
        if (closeAngle == -1) {
          buffer.write(html[i]);
          i++;
          continue;
        }

        final tag = html.substring(i + 1, closeAngle);

        // Yopiluvchi teg (</ ...) - skip
        if (tag.startsWith('/')) {
          i = closeAngle + 1;
          continue;
        }

        // CSS class ni ajratib olamiz
        String? cssClass;
        String tagName;

        if (tag.contains('class=')) {
          final classMatch = RegExp(r'class=([^\s>]+)').firstMatch(tag);
          cssClass = classMatch?.group(1);
        }

        // tagName (tajweed yoki span)
        tagName = tag.split(' ')[0].split('\n')[0];

        // Tegning yopilish joyini topamiz
        final closingTag = '</$tagName>';
        final closeIdx = html.indexOf(closingTag, closeAngle);

        if (closeIdx == -1) {
          // Yopilish yo'q — teg ichidagi matnni oddiy qo'shamiz
          i = closeAngle + 1;
          continue;
        }

        final innerText = html.substring(closeAngle + 1, closeIdx);
        if (innerText.isNotEmpty) {
          spans.add(TajweedSpan(text: innerText, cssClass: cssClass));
        }

        i = closeIdx + closingTag.length;
      } else {
        buffer.write(html[i]);
        i++;
      }
    }

    // Qolgan oddiy matn
    if (buffer.isNotEmpty) {
      spans.add(TajweedSpan(text: buffer.toString()));
    }

    return spans;
  }
}