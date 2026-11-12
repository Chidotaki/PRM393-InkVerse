import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/novel.dart';
import '../repositories/novel_repository.dart';

/// Provider managing public novel discovery, filtering, search, and sorting.
class NovelProvider extends ChangeNotifier {
  final NovelRepository novelRepository;
  StreamSubscription<List<Novel>>? _novelsSubscription;

  List<Novel> _novels = [];
  bool _loading = false;
  String? _error;

  String _searchQuery = '';
  String? _selectedGenre;
  NovelStatus? _selectedStatus;
  NovelSort _selectedSort = NovelSort.recentlyUpdated;

  NovelProvider({required this.novelRepository}) {
    _initStream();
  }

  // Getters
  List<Novel> get allNovels => List.unmodifiable(_novels);
  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedGenre => _selectedGenre;
  NovelStatus? get selectedStatus => _selectedStatus;
  NovelSort get selectedSort => _selectedSort;

  /// Derived pipeline: all public novels -> search -> genre filter -> status filter -> sort.
  List<Novel> get visibleNovels {
    List<Novel> result = List.from(_novels);

    // 1. Search Query (title or authorName, case-insensitive, trim-aware)
    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((novel) {
        final titleMatch = novel.title.toLowerCase().contains(query);
        final authorMatch = novel.authorName.toLowerCase().contains(query);
        return titleMatch || authorMatch;
      }).toList();
    }

    // 2. Genre Filter
    if (_selectedGenre != null && _selectedGenre!.isNotEmpty) {
      result = result.where((novel) {
        return novel.genres.any(
          (g) => g.toLowerCase() == _selectedGenre!.toLowerCase(),
        );
      }).toList();
    }

    // 3. Status Filter
    if (_selectedStatus != null) {
      result = result
          .where((novel) => novel.status == _selectedStatus)
          .toList();
    }

    // 4. Sorting (Never mutate original _novels list)
    switch (_selectedSort) {
      case NovelSort.recentlyUpdated:
        result.sort((a, b) {
          final timeA = a.updatedAt ?? a.createdAt ?? DateTime(0);
          final timeB = b.updatedAt ?? b.createdAt ?? DateTime(0);
          return timeB.compareTo(timeA);
        });
        break;
      case NovelSort.mostPopular:
        result.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case NovelSort.mostFollowed:
        result.sort((a, b) => b.followerCount.compareTo(a.followerCount));
        break;
      case NovelSort.titleAZ:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    return result;
  }

  void _initStream() {
    _loading = true;
    notifyListeners();

    _novelsSubscription = novelRepository.streamPublishedNovels().listen(
      (list) {
        _novels = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (err) {
        _error = AppException.from(err).message;
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchNovels() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _novels = await novelRepository.getPublishedNovels();
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Novel?> getNovelById(String id) async {
    try {
      final existing = _novels.where((n) => n.id == id);
      if (existing.isNotEmpty) return existing.first;
      return await novelRepository.getNovel(id);
    } catch (e) {
      _error = AppException.from(e).message;
      notifyListeners();
      return null;
    }
  }

  Future<void> recordView(String novelId) async {
    await novelRepository.incrementViewCount(novelId);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedGenre(String? genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  void setSelectedStatus(NovelStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSelectedSort(NovelSort sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedGenre = null;
    _selectedStatus = null;
    _selectedSort = NovelSort.recentlyUpdated;
    notifyListeners();
  }

  @override
  void dispose() {
    _novelsSubscription?.cancel();
    super.dispose();
  }
}
