import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../constants/firestore_collections.dart';
import '../../models/models.dart';

/// Development-only seeding utility for Cloud Firestore.
///
/// Strictly executed ONLY when `--dart-define=ENABLE_DEV_SEED=true` is set.
/// Seeds data ONLY if collections are currently empty.
/// NEVER wipes or overwrites existing production data.
class DevSeeder {
  DevSeeder._();

  static Future<void> seedIfEmpty(FirebaseFirestore firestore) async {
    try {
      final novelsRef = firestore.collection(FirestoreCollections.novels);
      final existingNovels = await novelsRef.limit(1).get();

      if (existingNovels.docs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[InkVerse Seed] Firestore already contains data. Seeding skipped.',
          );
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '[InkVerse Seed] Target collections are empty. Beginning dev seeding...',
        );
      }

      final now = DateTime.now();

      // 1. Seed Genres
      final genresRef = firestore.collection(FirestoreCollections.genres);
      final existingGenres = await genresRef.limit(1).get();
      if (existingGenres.docs.isEmpty) {
        final genreBatch = firestore.batch();
        for (final name in AppConstants.defaultGenres) {
          final doc = genresRef.doc();
          genreBatch.set(doc, {
            'id': doc.id,
            'name': name,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await genreBatch.commit();
        if (kDebugMode) {
          debugPrint(
            '[InkVerse Seed] Seeded ${AppConstants.defaultGenres.length} default genres.',
          );
        }
      }

      // 2. Seed Sample Public Novels & Chapters
      final sampleNovels = [
        Novel(
          id: 'dev_seed_novel_1',
          authorId: 'dev_seed_author_1',
          authorName: 'Bob Novelist',
          title: 'The Last Star Keeper',
          description: 'When the ancient celestial lanterns begin flickering out one by one, an apprentice starlight weaver embarks on a dangerous cosmic journey across dying nebulae.',
          coverUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=600',
          genres: const ['Sci-Fi', 'Adventure'],
          status: NovelStatus.ongoing,
          visibility: NovelVisibility.published,
          chapterCount: 2,
          viewCount: 1200,
          followerCount: 240,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 1)),
          publishedAt: now.subtract(const Duration(days: 28)),
        ),
        Novel(
          id: 'dev_seed_novel_2',
          authorId: 'dev_seed_author_1',
          authorName: 'Bob Novelist',
          title: 'Echoes Beyond Midnight',
          description: 'A detective with the ability to hear lingering auditory memories uncovers an unsolved murder deep within an abandoned Victorian asylum.',
          coverUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600',
          genres: const ['Mystery', 'Horror'],
          status: NovelStatus.ongoing,
          visibility: NovelVisibility.published,
          chapterCount: 1,
          viewCount: 650,
          followerCount: 110,
          createdAt: now.subtract(const Duration(days: 20)),
          updatedAt: now.subtract(const Duration(days: 3)),
          publishedAt: now.subtract(const Duration(days: 19)),
        ),
        Novel(
          id: 'dev_seed_novel_3',
          authorId: 'dev_seed_author_2',
          authorName: 'Elena Rostova',
          title: 'City of Glass Rivers',
          description: 'Beneath the transparent obsidian bridges of Oakhaven, a network of forgotten aqueducts carries memories distilled into luminous liquid glass.',
          coverUrl: 'https://images.unsplash.com/photo-1477959858617-67f30bc75b82?w=600',
          genres: const ['Fantasy', 'Mystery'],
          status: NovelStatus.ongoing,
          visibility: NovelVisibility.published,
          chapterCount: 1,
          viewCount: 1540,
          followerCount: 290,
          createdAt: now.subtract(const Duration(days: 45)),
          updatedAt: now.subtract(const Duration(days: 5)),
          publishedAt: now.subtract(const Duration(days: 42)),
        ),
      ];

      for (final novel in sampleNovels) {
        final novelDoc = novelsRef.doc(novel.id);
        final novelMap = novel.toMap();
        novelMap['createdAt'] = FieldValue.serverTimestamp();
        novelMap['updatedAt'] = FieldValue.serverTimestamp();
        novelMap['publishedAt'] = FieldValue.serverTimestamp();
        await novelDoc.set(novelMap);
      }

      // 3. Seed Chapters for Seed Novels
      final chaptersRef = firestore.collection(FirestoreCollections.chapters);
      final seedChapters = [
        Chapter(
          id: 'dev_seed_chap_1_1',
          novelId: 'dev_seed_novel_1',
          authorId: 'dev_seed_author_1',
          title: 'Chapter 1: The Dying Lantern',
          chapterNumber: 1,
          content: 'In the vast silence of the Aetherium, the stars do not simply vanish; they sigh.\n\nLyra stood upon the obsidian balustrade of the observatory, clutching her copper spools. Three miles above the sea of clouds, the Great Loom hummed with an uneasy, shuddering vibration. Through the brass lens, she watched the twelfth lantern of the Cygnus sector shudder once, flicker into dull amber, and extinguish entirely.\n\n"Master Donald," she called softly, her voice barely carrying over the wind. "Another beacon has ceased."',
          status: ChapterStatus.published,
          createdAt: now.subtract(const Duration(days: 28)),
          updatedAt: now.subtract(const Duration(days: 28)),
          publishedAt: now.subtract(const Duration(days: 28)),
          wordCount: 88,
        ),
        Chapter(
          id: 'dev_seed_chap_1_2',
          novelId: 'dev_seed_novel_1',
          authorId: 'dev_seed_author_1',
          title: 'Chapter 2: The Weave of Shadows',
          chapterNumber: 2,
          content: 'The road down the precipice was paved in frost and broken glass. As the solar winds surged, Lyra had to brace against the mountain wall. Her knapsack rattled with crystalline vials, each holding a pinch of condensed stardust.\n\nBehind them, the Great Loom fell silent for the first time in four hundred years. In its absence, the sky felt dangerously low and suffocatingly dark.',
          status: ChapterStatus.published,
          createdAt: now.subtract(const Duration(days: 15)),
          updatedAt: now.subtract(const Duration(days: 15)),
          publishedAt: now.subtract(const Duration(days: 15)),
          wordCount: 74,
        ),
        Chapter(
          id: 'dev_seed_chap_2_1',
          novelId: 'dev_seed_novel_2',
          authorId: 'dev_seed_author_1',
          title: 'Chapter 1: The Frequency of Guilt',
          chapterNumber: 1,
          content: 'To most ears, the abandoned corridors of St. Jude Asylum were dead silent. But to Inspector Vance, every cracked ceramic tile was screaming.\n\nHe pulled down the brass diaphragm of his resonator. Sound has memory; stone absorbs fear. At 440 Hertz, he could hear the faint chime of grandfather clocks long removed.',
          status: ChapterStatus.published,
          createdAt: now.subtract(const Duration(days: 19)),
          updatedAt: now.subtract(const Duration(days: 19)),
          publishedAt: now.subtract(const Duration(days: 19)),
          wordCount: 56,
        ),
        Chapter(
          id: 'dev_seed_chap_3_1',
          novelId: 'dev_seed_novel_3',
          authorId: 'dev_seed_author_2',
          title: 'Chapter 1: The Glassmaker’s Secret',
          chapterNumber: 1,
          content: 'Under the midnight arches of Oakhaven, the canals ran not with water, but with molten sapphire. Master Vane dipped his iron ladle into the river, scooping up a cup of liquid memory.',
          status: ChapterStatus.published,
          createdAt: now.subtract(const Duration(days: 42)),
          updatedAt: now.subtract(const Duration(days: 42)),
          publishedAt: now.subtract(const Duration(days: 42)),
          wordCount: 35,
        ),
      ];

      for (final chapter in seedChapters) {
        final chapDoc = chaptersRef.doc(chapter.id);
        final map = chapter.toMap();
        map['createdAt'] = FieldValue.serverTimestamp();
        map['updatedAt'] = FieldValue.serverTimestamp();
        map['publishedAt'] = FieldValue.serverTimestamp();
        await chapDoc.set(map);
      }

      if (kDebugMode) {
        debugPrint(
          '[InkVerse Seed] Seeded ${sampleNovels.length} novels and ${seedChapters.length} published chapters successfully.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InkVerse Seed] Seeding error (non-fatal): $e');
      }
    }
  }
}
