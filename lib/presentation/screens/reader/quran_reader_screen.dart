import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/verse_model.dart';
import '../../../data/models/word_model.dart';
import '../../providers/reader_provider.dart';
import '../../widgets/ayah_bottom_sheet.dart';
import '../../widgets/quran_page_text.dart';
import '../../../core/constants/app_colors.dart';

class QuranReaderScreen extends StatefulWidget {
  final ChapterModel chapter;

  const QuranReaderScreen({super.key, required this.chapter});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late ReaderProvider _provider;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _provider = ReaderProvider();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadChapter(widget.chapter.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _showVerseDetails(VerseModel verse) {
    _provider.selectVerse(verse);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AyahBottomSheet(
        verse: verse,
        chapterName: widget.chapter.nameSimple,
      ),
    ).whenComplete(() => _provider.selectVerse(null));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: const Color(0xFFD5C9A8),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Column(
            children: [
              Text(
                widget.chapter.nameArabic,
                style: const TextStyle(
                  fontFamily: 'UthmanicHafs',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.chapter.nameSimple,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Consumer<ReaderProvider>(
              builder: (_, provider, __) {
                if (provider.totalPages == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Text(
                      '${provider.currentPageIndex + 1}/${provider.totalPages}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<ReaderProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return _buildShimmer();

            if (provider.error.isNotEmpty && provider.pageLines.isEmpty) {
              return _buildError(() => provider.loadChapter(widget.chapter.id));
            }

            return _buildPagedReader(provider);
          },
        ),
      ),
    );
  }

  Widget _buildPagedReader(ReaderProvider provider) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: PageView.builder(
                controller: _pageController,
                itemCount: provider.totalPages,
                onPageChanged: provider.setPageIndex,
                itemBuilder: (context, index) {
                  final pageNum = provider.pageNumbers[index];
                  final lines = provider.pageLines[pageNum] ?? {};
                  final isFirstPage = index == 0;

                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: _buildMushafahPage(
                      lines: lines,
                      pageNum: pageNum,
                      showBismillah: isFirstPage &&
                          widget.chapter.id != 9 &&
                          widget.chapter.id != 1,
                      provider: provider,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        _buildBottomNav(provider),
      ],
    );
  }

  Widget _buildMushafahPage({
    required Map<int, List<WordModel>> lines,
    required int pageNum,
    required bool showBismillah,
    required ReaderProvider provider,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(-1, -1),
          ),
        ],
        border: Border.all(color: const Color(0xFFC8B98A), width: 1),
      ),
      child: Column(
        children: [
          _buildPageHeader(pageNum),
          if (showBismillah) _buildBismillah(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: QuranPageText(
                lines: lines,
                pageNumber: pageNum,
                verseLookup: provider.verseByKey,
                onVerseTap: _showVerseDetails,
              ),
            ),
          ),
          _buildPageFooter(pageNum),
        ],
      ),
    );
  }

  Widget _buildPageHeader(int pageNum) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFC8B98A), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.chapter.nameSimple,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            widget.chapter.nameArabic,
            style: const TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: 13,
              color: AppColors.primary,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
      child: Column(
        children: [
          Text(
            'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
            style: const TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: 22,
              color: Color(0xFF1B5E20),
              height: 2.0,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const Divider(color: Color(0xFFC8B98A), height: 12),
        ],
      ),
    );
  }

  Widget _buildPageFooter(int pageNum) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFC8B98A), width: 0.8),
        ),
      ),
      child: Center(
        child: Text(
          '— $pageNum —',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF888888),
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(ReaderProvider provider) {
    if (provider.totalPages == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(bottom: 12, top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: provider.currentPageIndex < provider.totalPages - 1
                ? () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.primary,
          ),
          Text(
            'Sahifa ${provider.currentQuranPageNumber}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: provider.currentPageIndex > 0
                ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                : null,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xFFC8B98A)),
        ),
        padding: const EdgeInsets.all(18),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              15,
              (i) => Container(
                height: 24,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Oyatlarni yuklashda xato'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Qayta urinish'),
          ),
        ],
      ),
    );
  }
}