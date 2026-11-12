import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/app_user.dart';
import '../models/content_report.dart';
import '../models/genre.dart';
import '../models/novel.dart';
import '../repositories/comment_repository.dart';
import '../repositories/genre_repository.dart';
import '../repositories/novel_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/user_repository.dart';

/// Metrics data model for Admin Dashboard
class AdminDashboardMetrics {
  final int totalUsers;
  final int totalAuthors;
  final int totalNovels;
  final int publishedNovels;
  final int pendingReports;
  final int totalComments;

  const AdminDashboardMetrics({
    this.totalUsers = 0,
    this.totalAuthors = 0,
    this.totalNovels = 0,
    this.publishedNovels = 0,
    this.pendingReports = 0,
    this.totalComments = 0,
  });
}

/// Provider managing admin capabilities: user management, novel moderation,
/// content reports, genres, and dashboard overview metrics.
class AdminProvider extends ChangeNotifier {
  final UserRepository userRepository;
  final NovelRepository novelRepository;
  final ReportRepository reportRepository;
  final GenreRepository genreRepository;
  final CommentRepository commentRepository;

  AdminDashboardMetrics _metrics = const AdminDashboardMetrics();
  List<AppUser> _users = [];
  List<Novel> _novels = [];
  List<ContentReport> _reports = [];
  List<Genre> _genres = [];

  bool _loading = false;
  bool _submitting = false;
  String? _error;

  AdminProvider({
    required this.userRepository,
    required this.novelRepository,
    required this.reportRepository,
    required this.genreRepository,
    required this.commentRepository,
  });

  // Getters
  AdminDashboardMetrics get metrics => _metrics;
  List<AppUser> get users => List.unmodifiable(_users);
  List<Novel> get novels => List.unmodifiable(_novels);
  List<ContentReport> get reports => List.unmodifiable(_reports);
  List<Genre> get genres => List.unmodifiable(_genres);
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Loads high-level dashboard metrics for the platform.
  Future<void> loadDashboardMetrics() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        userRepository.getAllUsers(),
        novelRepository.getAllNovels(),
        reportRepository.countPendingReports(),
        commentRepository.countTotalComments(),
      ]);

      final allUsers = results[0] as List<AppUser>;
      final allNovels = results[1] as List<Novel>;
      final pendingReports = results[2] as int;
      final totalComments = results[3] as int;

      final authorsCount = allUsers.where((u) => u.isAuthor).length;
      final publishedCount = allNovels.where((n) => n.isPublished).length;

      _metrics = AdminDashboardMetrics(
        totalUsers: allUsers.length,
        totalAuthors: authorsCount,
        totalNovels: allNovels.length,
        publishedNovels: publishedCount,
        pendingReports: pendingReports,
        totalComments: totalComments,
      );
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // --- User Management ---

  Future<void> loadUsers() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await userRepository.getAllUsers();
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setUserActive({
    required String uid,
    required bool isActive,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await userRepository.setUserActive(uid: uid, isActive: isActive);
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isActive: isActive);
      }
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  // --- Novel Moderation ---

  Future<void> loadAllNovels() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _novels = await novelRepository.getAllNovels();
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> hideNovel(String novelId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await novelRepository.hideNovel(novelId);
      final index = _novels.indexWhere((n) => n.id == novelId);
      if (index != -1) {
        _novels[index] = _novels[index].copyWith(
          visibility: NovelVisibility.hidden,
        );
      }
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> restoreNovel(String novelId) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await novelRepository.restoreNovel(novelId);
      final index = _novels.indexWhere((n) => n.id == novelId);
      if (index != -1) {
        _novels[index] = _novels[index].copyWith(
          visibility: NovelVisibility.published,
        );
      }
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  // --- Reports Moderation ---

  Future<void> loadReports({ReportStatus? status}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await reportRepository.getReports(status: status);
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> resolveReport({
    required String reportId,
    required String adminId,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await reportRepository.resolveReport(
        reportId: reportId,
        adminId: adminId,
      );
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWith(
          status: ReportStatus.resolved,
          reviewedAt: DateTime.now(),
          reviewedBy: adminId,
        );
      }
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> dismissReport({
    required String reportId,
    required String adminId,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await reportRepository.dismissReport(
        reportId: reportId,
        adminId: adminId,
      );
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWith(
          status: ReportStatus.dismissed,
          reviewedAt: DateTime.now(),
          reviewedBy: adminId,
        );
      }
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  // --- Genre Management ---

  Future<void> loadGenres() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _genres = await genreRepository.getAllGenres();
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String> addGenre(String name) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final id = await genreRepository.addGenre(name);
      await loadGenres();
      return id;
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> renameGenre({
    required String id,
    required String newName,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await genreRepository.renameGenre(id: id, newName: newName);
      await loadGenres();
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> setGenreActive({
    required String id,
    required bool isActive,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await genreRepository.setGenreActive(id: id, isActive: isActive);
      final index = _genres.indexWhere((g) => g.id == id);
      if (index != -1) {
        _genres[index] = _genres[index].copyWith(isActive: isActive);
      }
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
