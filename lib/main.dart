import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/quran_repository.dart';
import 'presentation/providers/quran_provider.dart';
import 'presentation/screens/home/surah_list_screen.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => QuranProvider(
            repository: QuranRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Quran Reader',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SurahListScreen(),
      ),
    );
  }
}