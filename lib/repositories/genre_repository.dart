import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../models/genre.dart';

abstract class GenreRepository {
  Future<List<Genre>> getActiveGenres();
  Future<List<Genre>> getAllGenres();
  Future<String> addGenre(String name);
  Future<void> renameGenre({required String id, required String newName});
  Future<void> setGenreActive({required String id, required bool isActive});
  Future<void> seedDefaultGenres();
}

class FirebaseGenreRepository implements GenreRepository {
  final FirebaseFirestore _firestore;

  FirebaseGenreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _genresCol =>
      _firestore.collection(FirestoreCollections.genres);

  @override
  Future<List<Genre>> getActiveGenres() async {
    try {
      final snapshot = await _genresCol
          .where('isActive', isEqualTo: true)
          .get();

      final list = snapshot.docs
          .map((doc) => Genre.fromMap(doc.data(), documentId: doc.id))
          .toList();

      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<Genre>> getAllGenres() async {
    try {
      final snapshot = await _genresCol.get();
      final list = snapshot.docs
          .map((doc) => Genre.fromMap(doc.data(), documentId: doc.id))
          .toList();

      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<String> addGenre(String name) async {
    try {
      final trimmed = name.trim();
      if (trimmed.isEmpty) {
        throw const ValidationException('Genre name cannot be empty.');
      }

      // Case-insensitive duplicate check
      final all = await getAllGenres();
      final exists = all.any(
        (g) => g.name.toLowerCase() == trimmed.toLowerCase(),
      );
      if (exists) {
        throw const ConflictException('A genre with this name already exists.');
      }

      final docRef = _genresCol.doc();
      final genre = Genre(
        id: docRef.id,
        name: trimmed,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = genre.toMap();
      map['createdAt'] = FieldValue.serverTimestamp();
      map['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(map);
      return docRef.id;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> renameGenre({
    required String id,
    required String newName,
  }) async {
    try {
      final trimmed = newName.trim();
      if (trimmed.isEmpty) {
        throw const ValidationException('Genre name cannot be empty.');
      }

      final all = await getAllGenres();
      final exists = all.any(
        (g) => g.id != id && g.name.toLowerCase() == trimmed.toLowerCase(),
      );
      if (exists) {
        throw const ConflictException('Another genre already uses this name.');
      }

      await _genresCol.doc(id).update({
        'name': trimmed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> setGenreActive({
    required String id,
    required bool isActive,
  }) async {
    try {
      await _genresCol.doc(id).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> seedDefaultGenres() async {
    try {
      final existing = await _genresCol.limit(1).get();
      if (existing.docs.isNotEmpty) {
        return; // Only seed if empty
      }

      final batch = _firestore.batch();
      final now = DateTime.now();

      for (final name in AppConstants.defaultGenres) {
        final docRef = _genresCol.doc();
        final genre = Genre(
          id: docRef.id,
          name: name,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );
        final map = genre.toMap();
        map['createdAt'] = FieldValue.serverTimestamp();
        map['updatedAt'] = FieldValue.serverTimestamp();
        batch.set(docRef, map);
      }

      await batch.commit();
    } catch (_) {
      // Non-blocking seeding error
    }
  }
}
