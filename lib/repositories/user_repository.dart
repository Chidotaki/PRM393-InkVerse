import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../models/app_user.dart';

abstract class UserRepository {
  Future<void> createUserProfile(AppUser user);
  Future<AppUser?> getUserProfile(String uid);
  Stream<AppUser?> streamUserProfile(String uid);
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String bio,
    required String avatarUrl,
  });
  Future<void> becomeAuthor(String uid);
  Future<List<AppUser>> getAllUsers();
  Future<void> setUserActive({required String uid, required bool isActive});
}

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Future<void> createUserProfile(AppUser user) async {
    try {
      final docRef = _usersCol.doc(user.uid);
      final existing = await docRef.get();
      if (!existing.exists) {
        await docRef.set(user.toMap());
      }
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCol.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!, documentId: doc.id);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Stream<AppUser?> streamUserProfile(String uid) {
    return _usersCol.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!, documentId: doc.id);
    });
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String bio,
    required String avatarUrl,
  }) async {
    try {
      final trimmedName = fullName.trim();
      if (trimmedName.isEmpty) {
        throw const ValidationException('Full name cannot be empty.');
      }

      // Security rule adherence: NEVER allow arbitrary role, isActive, or uid modification
      await _usersCol.doc(uid).update({
        'fullName': trimmedName,
        'bio': bio.trim(),
        'avatarUrl': avatarUrl.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> becomeAuthor(String uid) async {
    try {
      final docRef = _usersCol.doc(uid);
      final snapshot = await docRef.get();
      if (!snapshot.exists || snapshot.data() == null) {
        throw const NotFoundException('User profile not found.');
      }

      final currentUser = AppUser.fromMap(
        snapshot.data()!,
        documentId: snapshot.id,
      );

      // Business Rule: ONLY reader -> author transition allowed
      if (currentUser.role != UserRole.reader) {
        throw const ConflictException(
          'Only readers can transition to the author role.',
        );
      }

      await docRef.update({
        'role': UserRole.author.toValue(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _usersCol
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> setUserActive({
    required String uid,
    required bool isActive,
  }) async {
    try {
      await _usersCol.doc(uid).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
