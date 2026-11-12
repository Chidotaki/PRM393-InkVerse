import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../models/novel.dart';

abstract class NovelRepository {
  Stream<List<Novel>> streamPublishedNovels();
  Future<List<Novel>> getPublishedNovels();
  Future<Novel?> getNovel(String id);
  Future<void> incrementViewCount(String id);
  Future<String> createNovel(Novel novel);
  Future<void> updateNovel(Novel novel);
  Future<List<Novel>> getNovelsByAuthor(String authorId);
  Future<void> archiveNovel(String id, String authorId, {bool isAdmin = false});
  Future<void> publishNovel(String id, String authorId, {bool isAdmin = false});
  Future<List<Novel>> getAllNovels();
  Future<void> hideNovel(String id);
  Future<void> restoreNovel(String id);
}

class FirebaseNovelRepository implements NovelRepository {
  final FirebaseFirestore _firestore;

  FirebaseNovelRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _novelsCol =>
      _firestore.collection(FirestoreCollections.novels);

  CollectionReference<Map<String, dynamic>> get _chaptersCol =>
      _firestore.collection(FirestoreCollections.chapters);

  @override
  Stream<List<Novel>> streamPublishedNovels() {
    return _novelsCol
        .where('visibility', isEqualTo: NovelVisibility.published.toValue())
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Novel.fromMap(doc.data(), documentId: doc.id))
              .toList(),
        );
  }

  @override
  Future<List<Novel>> getPublishedNovels() async {
    try {
      final snapshot = await _novelsCol
          .where('visibility', isEqualTo: NovelVisibility.published.toValue())
          .get();
      return snapshot.docs
          .map((doc) => Novel.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<Novel?> getNovel(String id) async {
    try {
      final doc = await _novelsCol.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return Novel.fromMap(doc.data()!, documentId: doc.id);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> incrementViewCount(String id) async {
    try {
      await _novelsCol.doc(id).update({'viewCount': FieldValue.increment(1)});
    } catch (e) {
      // Fire-and-forget: do not block reading if counter fails
    }
  }

  @override
  Future<String> createNovel(Novel novel) async {
    try {
      // Business rules: Title, description, genres required
      if (novel.title.trim().isEmpty) {
        throw const ValidationException('Novel title cannot be empty.');
      }
      if (novel.description.trim().isEmpty) {
        throw const ValidationException('Novel description cannot be empty.');
      }
      if (novel.genres.isEmpty) {
        throw const ValidationException('At least one genre is required.');
      }

      final docRef = novel.id.isNotEmpty
          ? _novelsCol.doc(novel.id)
          : _novelsCol.doc();

      final initialNovel = novel.copyWith(
        id: docRef.id,
        visibility: NovelVisibility.draft,
        chapterCount: 0,
        viewCount: 0,
        followerCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = initialNovel.toMap();
      map['createdAt'] = FieldValue.serverTimestamp();
      map['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(map);
      return docRef.id;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> updateNovel(Novel novel) async {
    try {
      if (novel.title.trim().isEmpty) {
        throw const ValidationException('Novel title cannot be empty.');
      }
      if (novel.description.trim().isEmpty) {
        throw const ValidationException('Novel description cannot be empty.');
      }
      if (novel.genres.isEmpty) {
        throw const ValidationException('At least one genre is required.');
      }

      await _novelsCol.doc(novel.id).update({
        'title': novel.title.trim(),
        'description': novel.description.trim(),
        'coverUrl': novel.coverUrl.trim(),
        'genres': novel.genres,
        'status': novel.status.toValue(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<Novel>> getNovelsByAuthor(String authorId) async {
    try {
      final snapshot = await _novelsCol
          .where('authorId', isEqualTo: authorId)
          .get();
      return snapshot.docs
          .map((doc) => Novel.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> archiveNovel(
    String id,
    String authorId, {
    bool isAdmin = false,
  }) async {
    try {
      final doc = await _novelsCol.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundException('Novel not found.');
      }

      final novel = Novel.fromMap(doc.data()!, documentId: doc.id);
      if (!isAdmin && novel.authorId != authorId) {
        throw const PermissionDeniedException(
          'You can only archive your own novel.',
        );
      }

      // Soft archive: visibility = hidden
      await _novelsCol.doc(id).update({
        'visibility': NovelVisibility.hidden.toValue(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> publishNovel(
    String id,
    String authorId, {
    bool isAdmin = false,
  }) async {
    try {
      final doc = await _novelsCol.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundException('Novel not found.');
      }

      final novel = Novel.fromMap(doc.data()!, documentId: doc.id);
      if (!isAdmin && novel.authorId != authorId) {
        throw const PermissionDeniedException(
          'You can only publish your own novel.',
        );
      }

      if (novel.title.trim().isEmpty ||
          novel.description.trim().isEmpty ||
          novel.genres.isEmpty) {
        throw const ValidationException(
          'Novel title, description, and genres are required to publish.',
        );
      }

      // Query published chapters: must have at least one published chapter
      final chapterQuery = await _chaptersCol
          .where('novelId', isEqualTo: id)
          .where('status', isEqualTo: 'published')
          .limit(1)
          .get();

      if (chapterQuery.docs.isEmpty) {
        throw const ValidationException(
          'The novel must contain at least one published chapter before publishing.',
        );
      }

      final updates = <String, dynamic>{
        'visibility': NovelVisibility.published.toValue(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (novel.publishedAt == null) {
        updates['publishedAt'] = FieldValue.serverTimestamp();
      }

      await _novelsCol.doc(id).update(updates);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<Novel>> getAllNovels() async {
    try {
      final snapshot = await _novelsCol.get();
      return snapshot.docs
          .map((doc) => Novel.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> hideNovel(String id) async {
    try {
      await _novelsCol.doc(id).update({
        'visibility': NovelVisibility.hidden.toValue(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> restoreNovel(String id) async {
    try {
      await _novelsCol.doc(id).update({
        'visibility': NovelVisibility.published.toValue(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
