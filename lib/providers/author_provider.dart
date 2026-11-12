import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/chapter.dart';
import '../models/novel.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/novel_repository.dart';

/// Provider managing author actions: novel authoring, publishing, chapter management.
class AuthorProvider extends ChangeNotifier {
  final NovelRepository novelRepository;
  final ChapterRepository chapterRepository;

  List<Novel> _myNovels = [];
  final Map<String, List<Chapter>> _novelChapters = {};
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  AuthorProvider({
    required this.novelRepository,
    required this.chapterRepository,
  });

  // Getters
  List<Novel> get myNovels => List.unmodifiable(_myNovels);
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;

  List<Chapter> getChaptersForNovel(String novelId) =>
      List.unmodifiable(_novelChapters[novelId] ?? []);

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadMyNovels(String authorId) async {
    if (authorId.isEmpty) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _myNovels = await novelRepository.getNovelsByAuthor(authorId);
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String> createNovel({
    required String authorId,
    required String authorName,
    required String title,
    required String description,
    required List<String> genres,
    String coverUrl = '',
    NovelStatus status = NovelStatus.ongoing,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final novel = Novel(
        id: '',
        authorId: authorId,
        authorName: authorName,
        title: title.trim(),
        description: description.trim(),
        coverUrl: coverUrl.trim(),
        genres: genres,
        status: status,
        visibility: NovelVisibility.draft,
      );

      final novelId = await novelRepository.createNovel(novel);
      await loadMyNovels(authorId);
      return novelId;
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> updateNovel(Novel novel) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await novelRepository.updateNovel(novel);
      await loadMyNovels(novel.authorId);
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> archiveNovel(String novelId, String authorId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await novelRepository.archiveNovel(novelId, authorId);
      await loadMyNovels(authorId);
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> publishNovel(String novelId, String authorId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await novelRepository.publishNovel(novelId, authorId);
      await loadMyNovels(authorId);
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> loadChapters(String novelId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final chapters = await chapterRepository.getAuthorChapters(novelId);
      _novelChapters[novelId] = chapters;
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String> createChapter({
    required String novelId,
    required String authorId,
    required String title,
    required int chapterNumber,
    required String content,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final chapter = Chapter(
        id: '',
        novelId: novelId,
        authorId: authorId,
        title: title.trim(),
        chapterNumber: chapterNumber,
        content: content.trim(),
        status: ChapterStatus.draft,
      );

      final id = await chapterRepository.createChapter(chapter);
      await loadChapters(novelId);
      return id;
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> updateChapter(Chapter chapter) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await chapterRepository.updateChapter(chapter);
      await loadChapters(chapter.novelId);
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> publishChapter(String novelId, String chapterId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await chapterRepository.publishChapter(novelId, chapterId);
      await loadChapters(novelId);
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> unpublishChapter(String novelId, String chapterId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await chapterRepository.unpublishChapter(novelId, chapterId);
      await loadChapters(novelId);
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteDraftChapter(String novelId, String chapterId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await chapterRepository.deleteDraftChapter(novelId, chapterId);
      await loadChapters(novelId);
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
