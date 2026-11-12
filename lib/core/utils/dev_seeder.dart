import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';
import '../../models/novel.dart';
import '../constants/app_constants.dart';
import '../constants/firestore_collections.dart';
import 'date_time_util.dart';
import 'demo_catalog_data.dart';

/// Result summary returned by [DevSeeder.seedDemoCatalog].
class SeedResult {
  final bool success;
  final String message;
  final int novelsCreated;
  final int chaptersCreated;
  final int genresCreated;
  final int commentsCreated;
  final int novelsSkipped;
  final int chaptersSkipped;
  final int genresSkipped;
  final int commentsSkipped;

  const SeedResult({
    required this.success,
    required this.message,
    this.novelsCreated = 0,
    this.chaptersCreated = 0,
    this.genresCreated = 0,
    this.commentsCreated = 0,
    this.novelsSkipped = 0,
    this.chaptersSkipped = 0,
    this.genresSkipped = 0,
    this.commentsSkipped = 0,
  });

  const SeedResult.error(this.message)
    : success = false,
      novelsCreated = 0,
      chaptersCreated = 0,
      genresCreated = 0,
      commentsCreated = 0,
      novelsSkipped = 0,
      chaptersSkipped = 0,
      genresSkipped = 0,
      commentsSkipped = 0;

  @override
  String toString() =>
      'SeedResult(success: $success, message: "$message", novels: $novelsCreated, chapters: $chaptersCreated, genres: $genresCreated, comments: $commentsCreated)';
}

/// Development-only seeding utility for Cloud Firestore.
///
/// Strictly executed ONLY when `--dart-define=ENABLE_DEV_SEED=true` is set AND
/// triggered by an authenticated administrator.
///
/// Security & Idempotency Rules:
/// - Never runs before authentication.
/// - Requires active admin role.
/// - Author identity is set to the current admin's UID while preserving fictional author metadata.
/// - Uses deterministic document IDs and `.get()` existence checks.
/// - Never deletes, wipes, or overwrites existing records.
class DevSeeder {
  DevSeeder._();

  /// Converts a genre display name to a deterministic document ID.
  ///
  /// Examples:
  /// - "Fantasy" -> "genre_fantasy"
  /// - "Sci-Fi" -> "genre_scifi"
  /// - "Slice of Life" -> "genre_slice_of_life"
  static String genreDocId(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return 'genre_$slug';
  }

  /// Seeds demo catalog into Cloud Firestore if authorized.
  static Future<SeedResult> seedDemoCatalog({
    FirebaseFirestore? firestore,
    required String currentUserId,
    required String currentUserName,
    AppUser? currentUser,
  }) async {
    // 1. Verify compile-time feature flag
    if (!AppConstants.enableDevSeed) {
      return const SeedResult.error(
        'Development seeding is disabled. Run with --dart-define=ENABLE_DEV_SEED=true.',
      );
    }

    // 2. Verify authentication
    if (currentUserId.trim().isEmpty) {
      return const SeedResult.error(
        'Sign in with the development admin account before seeding demo content.',
      );
    }

    final db = firestore ?? FirebaseFirestore.instance;

    // 3. Verify user profile in Firestore
    try {
      final userDoc = await db
          .collection(FirestoreCollections.users)
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) {
        return const SeedResult.error(
          'Sign in with the development admin account before seeding demo content.',
        );
      }

      final userData = userDoc.data() ?? {};
      final role = (userData['role'] ?? '').toString().toLowerCase();
      final isActive = userData['isActive'] == true;

      if (!isActive) {
        return const SeedResult.error('This account is disabled.');
      }

      if (role != 'admin') {
        return const SeedResult.error(
          'Demo content can only be seeded by an administrator.',
        );
      }

      if (kDebugMode) {
        debugPrint(
          '[InkVerse DevSeeder] Authenticated admin verified: $currentUserId ($currentUserName). Beginning seed...',
        );
      }

      final now = DateTime.now();

      // 4. Seed Genres (Deterministic Document IDs)
      final genresRef = db.collection(FirestoreCollections.genres);
      int genresCreated = 0;
      int genresSkipped = 0;

      for (final name in AppConstants.defaultGenres) {
        final docId = genreDocId(name);
        final docRef = genresRef.doc(docId);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          await docRef.set({
            'id': docId,
            'name': name,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          genresCreated++;
        } else {
          genresSkipped++;
        }
      }

      // 5. Seed Demo Novels (Deterministic Document IDs, Admin ownership)
      final novelsRef = db.collection(FirestoreCollections.novels);
      final demoNovels = DemoCatalogData.getDemoNovels(now);
      int novelsCreated = 0;
      int novelsSkipped = 0;

      for (final novel in demoNovels) {
        final docRef = novelsRef.doc(novel.id);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          // Create initially as draft to satisfy Firestore create rule
          final novelDraft = novel.copyWith(
            authorId: currentUserId,
            visibility: NovelVisibility.draft,
          );
          await docRef.set(novelDraft.toMap());

          // Publish immediately to make visible to readers
          await docRef.update({
            'visibility': 'published',
            'publishedAt': DateTimeUtil.toFirestore(novel.publishedAt ?? now),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          novelsCreated++;
        } else {
          novelsSkipped++;
        }
      }

      // 6. Seed Demo Chapters (Deterministic Document IDs, Admin ownership)
      final chaptersRef = db.collection(FirestoreCollections.chapters);
      final demoChapters = DemoCatalogData.getDemoChapters(now);
      int chaptersCreated = 0;
      int chaptersSkipped = 0;

      for (final chapter in demoChapters) {
        final docRef = chaptersRef.doc(chapter.id);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          final chapterWithAdmin = chapter.copyWith(authorId: currentUserId);
          await docRef.set(chapterWithAdmin.toMap());
          chaptersCreated++;
        } else {
          chaptersSkipped++;
        }
      }

      // 7. Seed Showcase Comments (Deterministic Document IDs, Admin ownership)
      final commentsRef = db.collection(FirestoreCollections.comments);
      final demoComments = DemoCatalogData.getDemoComments(now);
      int commentsCreated = 0;
      int commentsSkipped = 0;

      for (final comment in demoComments) {
        final docRef = commentsRef.doc(comment.id);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          final commentWithAdmin = comment.copyWith(userId: currentUserId);
          await docRef.set(commentWithAdmin.toMap());
          commentsCreated++;
        } else {
          commentsSkipped++;
        }
      }

      final String summaryMessage =
          (novelsCreated > 0 ||
              chaptersCreated > 0 ||
              genresCreated > 0 ||
              commentsCreated > 0)
          ? 'Demo catalog ready: $novelsCreated novels, $chaptersCreated chapters, $genresCreated genres, $commentsCreated comments created.'
          : 'Demo catalog is already up to date ($novelsSkipped novels, $chaptersSkipped chapters, $genresSkipped genres preserved).';

      if (kDebugMode) {
        debugPrint('[InkVerse DevSeeder] $summaryMessage');
      }

      return SeedResult(
        success: true,
        message: summaryMessage,
        novelsCreated: novelsCreated,
        chaptersCreated: chaptersCreated,
        genresCreated: genresCreated,
        commentsCreated: commentsCreated,
        novelsSkipped: novelsSkipped,
        chaptersSkipped: chaptersSkipped,
        genresSkipped: genresSkipped,
        commentsSkipped: commentsSkipped,
      );
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[InkVerse DevSeeder] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      if (e.code == 'permission-denied') {
        return const SeedResult.error(
          'This account is not authorized to seed demo content.',
        );
      }
      return SeedResult.error('Seeding failed: ${e.message ?? e.code}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InkVerse DevSeeder] Unexpected error: $e');
      }
      return SeedResult.error('Seeding failed: $e');
    }
  }
}
