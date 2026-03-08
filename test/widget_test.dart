import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_text_test/main.dart';

void main() {
  testWidgets('Quran app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuranApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}