import 'package:flutter/material.dart';
import '../../data/models/verse_model.dart';
import 'word_widget.dart';

class AyahWidget extends StatelessWidget {
  final VerseModel verse;
  final bool isSelected;
  final VoidCallback onTap;

  const AyahWidget({
    super.key,
    required this.verse,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1B5E20).withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            alignment: WrapAlignment.start,
            children: verse.words.map((word) {
              return WordWidget(
                word: word,
                onTap: onTap,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}