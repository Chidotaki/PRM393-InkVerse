import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/chapter_comment.dart';
import '../models/content_report.dart';
import '../repositories/comment_repository.dart';
import '../repositories/report_repository.dart';

/// Provider managing reader comments and content reporting.
class SocialProvider extends ChangeNotifier {
  final CommentRepository commentRepository;
  final ReportRepository reportRepository;

  List<ChapterComment> _comments = [];
  bool _loading = false;
  bool _submitting = false;
  String? _error;

  SocialProvider({
    required this.commentRepository,
    required this.reportRepository,
  });

  // Getters
  List<ChapterComment> get comments => List.unmodifiable(_comments);
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadComments(String chapterId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _comments = await commentRepository.getCommentsForChapter(chapterId);
    } catch (e) {
      _error = AppException.from(e).message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addComment({
    required String userId,
    required String userName,
    required String novelId,
    required String chapterId,
    required String content,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final comment = ChapterComment(
        id: '',
        userId: userId,
        userName: userName,
        novelId: novelId,
        chapterId: chapterId,
        content: content.trim(),
      );

      final id = await commentRepository.addComment(comment);
      _comments.insert(0, comment.copyWith(id: id, createdAt: DateTime.now()));
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> editComment({
    required String commentId,
    required String userId,
    required String content,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await commentRepository.editOwnComment(
        commentId: commentId,
        userId: userId,
        content: content.trim(),
      );

      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index] = _comments[index].copyWith(
          content: content.trim(),
          updatedAt: DateTime.now(),
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

  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await commentRepository.deleteOwnComment(
        commentId: commentId,
        userId: userId,
      );
      _comments.removeWhere((c) => c.id == commentId);
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<String> submitReport({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String description = '',
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final report = ContentReport(
        id: '',
        reporterId: reporterId,
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        description: description,
      );

      final id = await reportRepository.submitReport(report);
      return id;
    } catch (e) {
      _error = AppException.from(e).message;
      rethrow;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
