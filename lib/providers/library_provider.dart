import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/bookmark.dart';
import '../models/reading_progress.dart';
import '../repositories/library_repository.dart';

/// Provider managing reader library: followed novels, bookmarks, and reading history.
class LibraryProvider extends ChangeNotifier {
  final LibraryRepository libraryRepository;

  Set<String> _followedNovelIds = {};
  List<Bookmark> _bookmarks = [];
  List<ReadingProgress> _readingHistory = [];
  bool _loading = false;
  String? _error;

  LibraryProvider({required this.libraryRepository});

  // Getters
  Set<String> get followedNovelIds => Set.unmodifiable(_followedNovelIds);
  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  List<ReadingProgress> get readingHistory =>
      List.unmodifiable(_readingHistory);
  bool get loading => _loading;
  String? get error => _error;

  bool isFollowing(String novelId) => _followedNovelIds.contains(novelId);

  bool isBookmarked(String novelId, String chapterId) =>
      _bookmarks.any((b) => b.novelId == novelId && b.chapterId == chapterId);

  Future<void> loadLibrary(String userId) async {
    if (userId.isEmpty) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        libraryRepository.getFollowedNovelIds(userId),
        libraryRepository.getBookmarks(userId),
        libraryRepository.getReadingHistory(userId),
      ]);

      _followedNovelIds = Set.from(results[0] as List<String>);
      _bookmarks = results[1] as List<Bookmark>;
      _readingHistory = results[2] as List<ReadingProgress>;
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> followNovel(String userId, String novelId) async {
    try {
      _followedNovelIds.add(novelId);
      notifyListeners();
      await libraryRepository.followNovel(userId, novelId);
    } catch (e) {
      _followedNovelIds.remove(novelId);
      _error = AppException.from(e).message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> unfollowNovel(String userId, String novelId) async {
    try {
      _followedNovelIds.remove(novelId);
      notifyListeners();
      await libraryRepository.unfollowNovel(userId, novelId);
    } catch (e) {
      _followedNovelIds.add(novelId);
      _error = AppException.from(e).message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleFollow(String userId, String novelId) async {
    if (isFollowing(novelId)) {
      await unfollowNovel(userId, novelId);
    } else {
      await followNovel(userId, novelId);
    }
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    try {
      _bookmarks.insert(0, bookmark);
      notifyListeners();
      await libraryRepository.addBookmark(bookmark);
    } catch (e) {
      _bookmarks.removeWhere((b) => b.id == bookmark.id);
      _error = AppException.from(e).message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeBookmark(
    String userId,
    String novelId,
    String chapterId,
  ) async {
    final existing = _bookmarks.firstWhere(
      (b) => b.novelId == novelId && b.chapterId == chapterId,
      orElse: () => Bookmark(
        id: '',
        userId: userId,
        novelId: novelId,
        chapterId: chapterId,
        chapterNumber: 0,
        novelTitle: '',
        chapterTitle: '',
      ),
    );

    try {
      _bookmarks.removeWhere(
        (b) => b.novelId == novelId && b.chapterId == chapterId,
      );
      notifyListeners();
      await libraryRepository.removeBookmark(userId, novelId, chapterId);
    } catch (e) {
      if (existing.id.isNotEmpty) {
        _bookmarks.add(existing);
      }
      _error = AppException.from(e).message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleBookmark(Bookmark bookmark) async {
    if (isBookmarked(bookmark.novelId, bookmark.chapterId)) {
      await removeBookmark(
        bookmark.userId,
        bookmark.novelId,
        bookmark.chapterId,
      );
    } else {
      await addBookmark(bookmark);
    }
  }

  Future<void> saveProgress(ReadingProgress progress) async {
    try {
      // Upsert in local list for instant UX
      _readingHistory.removeWhere((r) => r.novelId == progress.novelId);
      _readingHistory.insert(0, progress);
      notifyListeners();

      await libraryRepository.saveReadingProgress(progress);
    } catch (e) {
      _error = AppException.from(e).message;
      notifyListeners();
    }
  }

  Future<ReadingProgress?> getProgressForNovel(
    String userId,
    String novelId,
  ) async {
    final local = _readingHistory.where((r) => r.novelId == novelId);
    if (local.isNotEmpty) return local.first;
    return await libraryRepository.getReadingProgress(userId, novelId);
  }
}
