import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../constants/firestore_collections.dart';
import 'demo_catalog_data.dart';

/// Development-only seeding utility for Cloud Firestore.
///
/// Strictly executed ONLY when `--dart-define=ENABLE_DEV_SEED=true` is set.
/// Seeds data idempotently based on document IDs:
/// - Only creates missing documents.
/// - NEVER wipes or overwrites existing user data or production documents.
/// - Running repeatedly will never create duplicate novels or chapters.
class DevSeeder {
  DevSeeder._();

  static Future<void> seedIfEmpty(FirebaseFirestore firestore) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[InkVerse Seed] Running idempotent demo catalog verification...',
        );
      }

      final now = DateTime.now();

      // 1. Seed Genres (Idempotent per genre name)
      final genresRef = firestore.collection(FirestoreCollections.genres);
      int genresCreated = 0;
      for (final name in AppConstants.defaultGenres) {
        final query = await genresRef
            .where('name', isEqualTo: name)
            .limit(1)
            .get();
        if (query.docs.isEmpty) {
          final doc = genresRef.doc();
          await doc.set({
            'id': doc.id,
            'name': name,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          genresCreated++;
        }
      }

      // 2. Seed Realistic Demo Novels (Idempotent per document ID)
      final novelsRef = firestore.collection(FirestoreCollections.novels);
      final demoNovels = DemoCatalogData.getDemoNovels(now);
      int novelsCreated = 0;

      for (final novel in demoNovels) {
        final docRef = novelsRef.doc(novel.id);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          await docRef.set(novel.toMap());
          novelsCreated++;
        }
      }

      // 3. Seed Demo Chapters (Idempotent per document ID)
      final chaptersRef = firestore.collection(FirestoreCollections.chapters);
      final demoChapters = DemoCatalogData.getDemoChapters(now);
      int chaptersCreated = 0;

      for (final chapter in demoChapters) {
        final docRef = chaptersRef.doc(chapter.id);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          await docRef.set(chapter.toMap());
          chaptersCreated++;
        }
      }

      // 4. Seed Showcase Comments (Idempotent per document ID)
      final commentsRef = firestore.collection(FirestoreCollections.comments);
      final demoComments = DemoCatalogData.getDemoComments(now);
      int commentsCreated = 0;

      for (final comment in demoComments) {
        final docRef = commentsRef.doc(comment.id);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          await docRef.set(comment.toMap());
          commentsCreated++;
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[InkVerse Seed] Complete! Created: $novelsCreated novels, $chaptersCreated chapters, $genresCreated genres, $commentsCreated comments.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InkVerse Seed] Seeding error (non-fatal): $e');
      }
    }
  }
}
