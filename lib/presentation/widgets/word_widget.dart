import 'package:flutter/material.dart';
import '../../data/models/word_model.dart';

class WordWidget extends StatelessWidget {
  final WordModel word;
  final VoidCallback? onTap;

  const WordWidget({
    super.key,
    required this.word,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (word.charTypeName == 'end') {
      return _buildEndMarker();
    }

    const color = Color(0xFF212121);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Text(
          word.text,
          style: TextStyle(
            fontSize: 24,
            color: color,
            height: 2.0,
            fontFamily: 'UthmanicHafs',
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildEndMarker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        word.text,
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xFF1B5E20),
          height: 2.0,
          fontFamily: 'UthmanicHafs',
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}