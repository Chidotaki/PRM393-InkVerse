import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../models/chapter.dart';

abstract class ChapterRepository {
  Future<List<Chapter>> getPublishedChapters(String novelId);
  Future<List<Chapter>> getAuthorChapters(String novelId);
  Future<Chapter?> getChapter(String chapterId);
  Future<String> createChapter(Chapter chapter);
  Future<void> updateChapter(Chapter chapter);
  Future<void> publishChapter(String novelId, String chapterId);
  Future<void> unpublishChapter(String novelId, String chapterId);
  Future<void> deleteDraftChapter(String novelId, String chapterId);
  Future<Chapter?> getPreviousChapter(String novelId, int currentChapterNumber);
  Future<Chapter?> getNextChapter(String novelId, int currentChapterNumber);
}

class FirebaseChapterRepository implements ChapterRepository {
  final FirebaseFirestore _firestore;

  FirebaseChapterRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chaptersCol =>
      _firestore.collection(FirestoreCollections.chapters);

  CollectionReference<Map<String, dynamic>> get _novelsCol =>
      _firestore.collection(FirestoreCollections.novels);

  @override
  Future<List<Chapter>> getPublishedChapters(String novelId) async {
    try {
      final snapshot = await _chaptersCol
          .where('novelId', isEqualTo: novelId)
          .where('status', isEqualTo: ChapterStatus.published.toValue())
          .get();

      final list = snapshot.docs
          .map((doc) => Chapter.fromMap(doc.data(), documentId: doc.id))
          .toList();

      // Sort client-side by chapterNumber ascending
      list.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
      return list;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<Chapter>> getAuthorChapters(String novelId) async {
    try {
      final snapshot = await _chaptersCol
          .where('novelId', isEqualTo: novelId)
          .get();

      final list = snapshot.docs
          .map((doc) => Chapter.fromMap(doc.data(), documentId: doc.id))
          .toList();

      list.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
      return list;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<Chapter?> getChapter(String chapterId) async {
    try {
      final doc = await _chaptersCol.doc(chapterId).get();
      if (!doc.exists || doc.data() == null) return null;
      return Chapter.fromMap(doc.data()!, documentId: doc.id);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<String> createChapter(Chapter chapter) async {
    try {
      if (chapter.chapterNumber <= 0) {
        throw const ValidationException(
          'Chapter number must be a positive number.',
        );
      }
      if (chapter.title.trim().isEmpty) {
        throw const ValidationException('Chapter title cannot be empty.');
      }
      if (chapter.content.trim().isEmpty) {
        throw const ValidationException('Chapter content cannot be empty.');
      }

      // Business Rule: Ensure unique chapter number within this novel
      final duplicateQuery = await _chaptersCol
          .where('novelId', isEqualTo: chapter.novelId)
          .where('chapterNumber', isEqualTo: chapter.chapterNumber)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        throw const ConflictException(
          'A chapter with this number already exists.',
        );
      }

      final docRef = chapter.id.isNotEmpty
          ? _chaptersCol.doc(chapter.id)
          : _chaptersCol.doc();

      final wordCount = Chapter.calculateWordCount(chapter.content);
      final initialChapter = chapter.copyWith(
        id: docRef.id,
        status: ChapterStatus.draft,
        wordCount: wordCount,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = initialChapter.toMap();
      map['createdAt'] = FieldValue.serverTimestamp();
      map['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(map);
      return docRef.id;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> updateChapter(Chapter chapter) async {
    try {
      if (chapter.chapterNumber <= 0) {
        throw const ValidationException(
          'Chapter number must be a positive number.',
        );
      }
      if (chapter.title.trim().isEmpty) {
        throw const ValidationException('Chapter title cannot be empty.');
      }
      if (chapter.content.trim().isEmpty) {
        throw const ValidationException('Chapter content cannot be empty.');
      }

      // Check duplicate chapter number excluding this chapter
      final duplicateQuery = await _chaptersCol
          .where('novelId', isEqualTo: chapter.novelId)
          .where('chapterNumber', isEqualTo: chapter.chapterNumber)
          .get();

      final conflicting = duplicateQuery.docs.where(
        (doc) => doc.id != chapter.id,
      );
      if (conflicting.isNotEmpty) {
        throw const ConflictException(
          'A chapter with this number already exists.',
        );
      }

      final wordCount = Chapter.calculateWordCount(chapter.content);

      await _chaptersCol.doc(chapter.id).update({
        'title': chapter.title.trim(),
        'chapterNumber': chapter.chapterNumber,
        'content': chapter.content.trim(),
        'wordCount': wordCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> publishChapter(String novelId, String chapterId) async {
    try {
      final docRef = _chaptersCol.doc(chapterId);
      final snapshot = await docRef.get();
      if (!snapshot.exists || snapshot.data() == null) {
        throw const NotFoundException('Chapter not found.');
      }

      final chapter = Chapter.fromMap(
        snapshot.data()!,
        documentId: snapshot.id,
      );

      final updates = <String, dynamic>{
        'status': ChapterStatus.published.toValue(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (chapter.publishedAt == null) {
        updates['publishedAt'] = FieldValue.serverTimestamp();
      }

      await docRef.update(updates);
      await _syncNovelPublishedChapterCount(novelId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> unpublishChapter(String novelId, String chapterId) async {
    try {
      await _chaptersCol.doc(chapterId).update({
        'status': ChapterStatus.draft.toValue(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _syncNovelPublishedChapterCount(novelId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> deleteDraftChapter(String novelId, String chapterId) async {
    try {
      final doc = await _chaptersCol.doc(chapterId).get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundException('Chapter not found.');
      }

      final chapter = Chapter.fromMap(doc.data()!, documentId: doc.id);
      if (chapter.status != ChapterStatus.draft) {
        throw const ConflictException('Only draft chapters can be deleted.');
      }

      await _chaptersCol.doc(chapterId).delete();
      await _syncNovelPublishedChapterCount(novelId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Recalculates and updates published chapter count on the parent Novel.
  Future<void> _syncNovelPublishedChapterCount(String novelId) async {
    try {
      final publishedSnapshot = await _chaptersCol
          .where('novelId', isEqualTo: novelId)
          .where('status', isEqualTo: ChapterStatus.published.toValue())
          .get();

      final count = publishedSnapshot.docs.length;

      await _novelsCol.doc(novelId).update({
        'chapterCount': count,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Non-blocking sync failure
    }
  }

  @override
  Future<Chapter?> getPreviousChapter(
    String novelId,
    int currentChapterNumber,
  ) async {
    try {
      final chapters = await getPublishedChapters(novelId);
      final prevList = chapters
          .where((c) => c.chapterNumber < currentChapterNumber)
          .toList();
      if (prevList.isEmpty) return null;
      return prevList.last; // Since list is sorted ascending
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<Chapter?> getNextChapter(
    String novelId,
    int currentChapterNumber,
  ) async {
    try {
      final chapters = await getPublishedChapters(novelId);
      final nextList = chapters
          .where((c) => c.chapterNumber > currentChapterNumber)
          .toList();
      if (nextList.isEmpty) return null;
      return nextList.first; // Since list is sorted ascending
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
