import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../models/bookmark.dart';
import '../models/follow.dart';
import '../models/reading_progress.dart';

abstract class LibraryRepository {
  Future<void> followNovel(String userId, String novelId);
  Future<void> unfollowNovel(String userId, String novelId);
  Future<bool> isFollowing(String userId, String novelId);
  Future<List<String>> getFollowedNovelIds(String userId);

  Future<void> addBookmark(Bookmark bookmark);
  Future<void> removeBookmark(String userId, String novelId, String chapterId);
  Future<bool> isBookmarked(String userId, String novelId, String chapterId);
  Future<List<Bookmark>> getBookmarks(String userId);

  Future<void> saveReadingProgress(ReadingProgress progress);
  Future<ReadingProgress?> getReadingProgress(String userId, String novelId);
  Future<List<ReadingProgress>> getReadingHistory(String userId);
}

class FirebaseLibraryRepository implements LibraryRepository {
  final FirebaseFirestore _firestore;

  FirebaseLibraryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _followsCol =>
      _firestore.collection(FirestoreCollections.follows);

  CollectionReference<Map<String, dynamic>> get _bookmarksCol =>
      _firestore.collection(FirestoreCollections.bookmarks);

  CollectionReference<Map<String, dynamic>> get _readingCol =>
      _firestore.collection(FirestoreCollections.readingProgress);

  CollectionReference<Map<String, dynamic>> get _novelsCol =>
      _firestore.collection(FirestoreCollections.novels);

  @override
  Future<void> followNovel(String userId, String novelId) async {
    try {
      final docId = Follow.generateId(userId, novelId);
      final followDoc = _followsCol.doc(docId);
      final novelDoc = _novelsCol.doc(novelId);

      await _firestore.runTransaction((transaction) async {
        final existingFollow = await transaction.get(followDoc);
        if (!existingFollow.exists) {
          final follow = Follow.create(userId: userId, novelId: novelId);
          final map = follow.toMap();
          map['createdAt'] = FieldValue.serverTimestamp();
          transaction.set(followDoc, map);

          transaction.update(novelDoc, {
            'followerCount': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> unfollowNovel(String userId, String novelId) async {
    try {
      final docId = Follow.generateId(userId, novelId);
      final followDoc = _followsCol.doc(docId);
      final novelDoc = _novelsCol.doc(novelId);

      await _firestore.runTransaction((transaction) async {
        final existingFollow = await transaction.get(followDoc);
        if (existingFollow.exists) {
          transaction.delete(followDoc);

          final novelSnapshot = await transaction.get(novelDoc);
          if (novelSnapshot.exists) {
            final currentFollowers =
                (novelSnapshot.data()?['followerCount'] as num?)?.toInt() ?? 0;
            final updated = currentFollowers > 0 ? currentFollowers - 1 : 0;
            transaction.update(novelDoc, {'followerCount': updated});
          }
        }
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<bool> isFollowing(String userId, String novelId) async {
    try {
      final docId = Follow.generateId(userId, novelId);
      final doc = await _followsCol.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<String>> getFollowedNovelIds(String userId) async {
    try {
      final snapshot = await _followsCol
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => doc.data()['novelId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> addBookmark(Bookmark bookmark) async {
    try {
      final docId = Bookmark.generateId(
        bookmark.userId,
        bookmark.novelId,
        bookmark.chapterId,
      );
      final map = bookmark.toMap();
      map['createdAt'] = FieldValue.serverTimestamp();
      await _bookmarksCol.doc(docId).set(map);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> removeBookmark(
    String userId,
    String novelId,
    String chapterId,
  ) async {
    try {
      final docId = Bookmark.generateId(userId, novelId, chapterId);
      await _bookmarksCol.doc(docId).delete();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<bool> isBookmarked(
    String userId,
    String novelId,
    String chapterId,
  ) async {
    try {
      final docId = Bookmark.generateId(userId, novelId, chapterId);
      final doc = await _bookmarksCol.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<Bookmark>> getBookmarks(String userId) async {
    try {
      final snapshot = await _bookmarksCol
          .where('userId', isEqualTo: userId)
          .get();

      final list = snapshot.docs
          .map((doc) => Bookmark.fromMap(doc.data(), documentId: doc.id))
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
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    try {
      final docId = ReadingProgress.generateId(
        progress.userId,
        progress.novelId,
      );
      final map = progress.toMap();
      map['lastReadAt'] = FieldValue.serverTimestamp();
      await _readingCol.doc(docId).set(map, SetOptions(merge: true));
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<ReadingProgress?> getReadingProgress(
    String userId,
    String novelId,
  ) async {
    try {
      final docId = ReadingProgress.generateId(userId, novelId);
      final doc = await _readingCol.doc(docId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ReadingProgress.fromMap(doc.data()!, documentId: doc.id);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<ReadingProgress>> getReadingHistory(String userId) async {
    try {
      final snapshot = await _readingCol
          .where('userId', isEqualTo: userId)
          .get();

      final list = snapshot.docs
          .map((doc) => ReadingProgress.fromMap(doc.data(), documentId: doc.id))
          .toList();

      list.sort(
        (a, b) => (b.lastReadAt ?? DateTime(0)).compareTo(
          a.lastReadAt ?? DateTime(0),
        ),
      );
      return list;
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
