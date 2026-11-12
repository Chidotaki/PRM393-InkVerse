import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../models/chapter_comment.dart';

abstract class CommentRepository {
  Future<List<ChapterComment>> getCommentsForChapter(String chapterId);
  Future<String> addComment(ChapterComment comment);
  Future<void> editOwnComment({
    required String commentId,
    required String userId,
    required String content,
  });
  Future<void> deleteOwnComment({
    required String commentId,
    required String userId,
  });
  Future<void> adminHideComment(String commentId);
  Future<int> countTotalComments();
}

class FirebaseCommentRepository implements CommentRepository {
  final FirebaseFirestore _firestore;

  FirebaseCommentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _commentsCol =>
      _firestore.collection(FirestoreCollections.comments);

  @override
  Future<List<ChapterComment>> getCommentsForChapter(String chapterId) async {
    try {
      final snapshot = await _commentsCol
          .where('chapterId', isEqualTo: chapterId)
          .get();

      final list = snapshot.docs
          .map((doc) => ChapterComment.fromMap(doc.data(), documentId: doc.id))
          .where((c) => !c.isDeleted)
          .toList();

      list.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
      return list;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<String> addComment(ChapterComment comment) async {
    try {
      final trimmed = comment.content.trim();
      if (trimmed.isEmpty) {
        throw const ValidationException('Comment content cannot be empty.');
      }

      final docRef = comment.id.isNotEmpty
          ? _commentsCol.doc(comment.id)
          : _commentsCol.doc();

      final map = comment
          .copyWith(
            id: docRef.id,
            content: trimmed,
            isDeleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
          .toMap();

      map['createdAt'] = FieldValue.serverTimestamp();
      map['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(map);
      return docRef.id;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> editOwnComment({
    required String commentId,
    required String userId,
    required String content,
  }) async {
    try {
      final trimmed = content.trim();
      if (trimmed.isEmpty) {
        throw const ValidationException('Comment content cannot be empty.');
      }

      final doc = await _commentsCol.doc(commentId).get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundException('Comment not found.');
      }

      final existing = ChapterComment.fromMap(doc.data()!, documentId: doc.id);
      if (existing.userId != userId) {
        throw const PermissionDeniedException(
          'You can only edit your own comment.',
        );
      }

      await _commentsCol.doc(commentId).update({
        'content': trimmed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> deleteOwnComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      final doc = await _commentsCol.doc(commentId).get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundException('Comment not found.');
      }

      final existing = ChapterComment.fromMap(doc.data()!, documentId: doc.id);
      if (existing.userId != userId) {
        throw const PermissionDeniedException(
          'You can only delete your own comment.',
        );
      }

      // Soft delete: isDeleted = true
      await _commentsCol.doc(commentId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> adminHideComment(String commentId) async {
    try {
      await _commentsCol.doc(commentId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<int> countTotalComments() async {
    try {
      final snapshot = await _commentsCol.get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
