import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/chapter.dart';
import '../models/novel.dart';
import '../models/reading_progress.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/library_repository.dart';

/// Provider managing active chapter reading session and user reading preferences.
class ReadingProvider extends ChangeNotifier {
  final ChapterRepository chapterRepository;
  final LibraryRepository libraryRepository;

  Chapter? _currentChapter;
  List<Chapter> _publishedChapters = [];
  bool _loading = false;
  String? _error;

  // Reading preferences
  double _fontSize = AppConstants.defaultFontSize;
  double _lineSpacing = AppConstants.defaultLineSpacing;
  String _readingTheme =
      AppConstants.defaultReadingTheme; // 'light', 'dark', 'sepia'

  ReadingProvider({
    required this.chapterRepository,
    required this.libraryRepository,
  }) {
    _loadPreferences();
  }

  // Getters
  Chapter? get currentChapter => _currentChapter;
  List<Chapter> get publishedChapters => List.unmodifiable(_publishedChapters);
  bool get loading => _loading;
  String? get error => _error;

  double get fontSize => _fontSize;
  double get lineSpacing => _lineSpacing;
  String get readingTheme => _readingTheme;

  bool get hasPreviousChapter {
    if (_currentChapter == null) return false;
    return _publishedChapters.any(
      (c) => c.chapterNumber < _currentChapter!.chapterNumber,
    );
  }

  bool get hasNextChapter {
    if (_currentChapter == null) return false;
    return _publishedChapters.any(
      (c) => c.chapterNumber > _currentChapter!.chapterNumber,
    );
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fontSize =
          prefs.getDouble(AppConstants.prefFontSize) ??
          AppConstants.defaultFontSize;
      _lineSpacing =
          prefs.getDouble(AppConstants.prefLineSpacing) ??
          AppConstants.defaultLineSpacing;
      _readingTheme =
          prefs.getString(AppConstants.prefReadingTheme) ??
          AppConstants.defaultReadingTheme;
      notifyListeners();
    } catch (_) {
      // Use defaults if prefs fail
    }
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(12.0, 32.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.prefFontSize, _fontSize);
  }

  Future<void> setLineSpacing(double spacing) async {
    _lineSpacing = spacing.clamp(1.2, 2.4);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.prefLineSpacing, _lineSpacing);
  }

  Future<void> setReadingTheme(String theme) async {
    if (['light', 'dark', 'sepia'].contains(theme)) {
      _readingTheme = theme;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefReadingTheme, _readingTheme);
    }
  }

  /// Loads chapter and chapter list for a novel.
  /// Automatically records chapter-level reading progress for logged-in user.
  Future<void> loadChapter({
    required String novelId,
    required String chapterId,
    String? userId,
    Novel? novel,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        chapterRepository.getChapter(chapterId),
        chapterRepository.getPublishedChapters(novelId),
      ]);

      _currentChapter = results[0] as Chapter?;
      _publishedChapters = results[1] as List<Chapter>;

      if (_currentChapter == null) {
        throw const NotFoundException('Chapter not found.');
      }

      // Upsert reading progress if user is signed in
      if (userId != null && userId.isNotEmpty) {
        final progress = ReadingProgress.create(
          userId: userId,
          novelId: novelId,
          novelTitle: novel?.title ?? 'Novel',
          coverUrl: novel?.coverUrl ?? '',
          chapterId: _currentChapter!.id,
          chapterTitle: _currentChapter!.title,
          chapterNumber: _currentChapter!.chapterNumber,
          progressPercent: 1.0,
        );
        await libraryRepository.saveReadingProgress(progress);
      }
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Navigates to previous published chapter if available.
  Future<Chapter?> goToPreviousChapter({String? userId, Novel? novel}) async {
    if (_currentChapter == null) return null;
    final prev = await chapterRepository.getPreviousChapter(
      _currentChapter!.novelId,
      _currentChapter!.chapterNumber,
    );
    if (prev != null) {
      await loadChapter(
        novelId: prev.novelId,
        chapterId: prev.id,
        userId: userId,
        novel: novel,
      );
    }
    return prev;
  }

  /// Navigates to next published chapter if available.
  Future<Chapter?> goToNextChapter({String? userId, Novel? novel}) async {
    if (_currentChapter == null) return null;
    final next = await chapterRepository.getNextChapter(
      _currentChapter!.novelId,
      _currentChapter!.chapterNumber,
    );
    if (next != null) {
      await loadChapter(
        novelId: next.novelId,
        chapterId: next.id,
        userId: userId,
        novel: novel,
      );
    }
    return next;
  }

  /// Updates scroll progress percent (0.0 to 1.0).
  Future<void> updateScrollProgress({
    required String userId,
    required Novel novel,
    required double progressPercent,
  }) async {
    if (_currentChapter == null) return;
    final progress = ReadingProgress.create(
      userId: userId,
      novelId: novel.id,
      novelTitle: novel.title,
      coverUrl: novel.coverUrl,
      chapterId: _currentChapter!.id,
      chapterTitle: _currentChapter!.title,
      chapterNumber: _currentChapter!.chapterNumber,
      progressPercent: progressPercent.clamp(0.0, 1.0),
    );
    await libraryRepository.saveReadingProgress(progress);
  }
}
