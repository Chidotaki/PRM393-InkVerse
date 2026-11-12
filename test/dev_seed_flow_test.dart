import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkverse/core/constants/app_constants.dart';
import 'package:inkverse/core/utils/demo_catalog_data.dart';
import 'package:inkverse/core/utils/dev_seeder.dart';
import 'package:inkverse/providers/auth_provider.dart';
import 'package:inkverse/providers/library_provider.dart';
import 'package:inkverse/providers/novel_provider.dart';
import 'package:inkverse/providers/reading_provider.dart';
import 'package:inkverse/repositories/mock/mock_repositories.dart';
import 'package:inkverse/screens/reader/profile_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('DevSeeder Deterministic IDs & Demo Catalog', () {
    test('genreDocId generates consistent deterministic document IDs', () {
      expect(DevSeeder.genreDocId('Fantasy'), equals('genre_fantasy'));
      expect(DevSeeder.genreDocId('Romance'), equals('genre_romance'));
      expect(DevSeeder.genreDocId('Mystery'), equals('genre_mystery'));
      expect(DevSeeder.genreDocId('Sci-Fi'), equals('genre_scifi'));
      expect(DevSeeder.genreDocId('Adventure'), equals('genre_adventure'));
      expect(DevSeeder.genreDocId('Historical'), equals('genre_historical'));
      expect(
        DevSeeder.genreDocId('Slice of Life'),
        equals('genre_slice_of_life'),
      );
      expect(DevSeeder.genreDocId('Thriller'), equals('genre_thriller'));
    });

    test('Demo novels catalog uses deterministic document IDs and valid published status', () {
      final now = DateTime.now();
      final novels = DemoCatalogData.getDemoNovels(now);

      expect(novels.length, equals(10));
      for (final novel in novels) {
        expect(novel.id, startsWith('demo_novel_'));
        expect(novel.title.isNotEmpty, isTrue);
        expect(novel.authorName.isNotEmpty, isTrue);
        expect(novel.genres.isNotEmpty, isTrue);
      }

      final chapters = DemoCatalogData.getDemoChapters(now);
      expect(chapters.length, greaterThanOrEqualTo(30));
      for (final ch in chapters) {
        expect(ch.id, startsWith('demo_'));
        expect(ch.novelId, startsWith('demo_novel_'));
        expect(ch.chapterNumber, greaterThan(0));
        expect(ch.content.isNotEmpty, isTrue);
      }
    });

    test(
      'DevSeeder rejects unauthenticated call with clear user message',
      () async {
        // Calling without currentUserId
        final result = await DevSeeder.seedDemoCatalog(
          currentUserId: '',
          currentUserName: 'Anonymous',
        );

        expect(result.success, isFalse);
        expect(
          result.message.contains(
                'Sign in with the development admin account',
              ) ||
              result.message.contains('Development seeding is disabled'),
          isTrue,
        );
      },
    );
  });

  group('ProfileScreen Development Tools Gating', () {
    testWidgets(
      'Development tools are hidden by default when ENABLE_DEV_SEED is false',
      (tester) async {
        final mockAuth = MockAuthService();
        final mockUser = MockUserRepository();
        final mockNovel = MockNovelRepository();
        final mockChapter = MockChapterRepository(mockNovel);
        final mockLibrary = MockLibraryRepository(mockNovel);

        final authProvider = AuthProvider(
          authService: mockAuth,
          userRepository: mockUser,
        );
        final libraryProvider = LibraryProvider(libraryRepository: mockLibrary);
        final readingProvider = ReadingProvider(
          chapterRepository: mockChapter,
          libraryRepository: mockLibrary,
        );
        final novelProvider = NovelProvider(novelRepository: mockNovel);

        // Authenticate as a normal reader
        await mockAuth.login(
          email: 'reader@inkverse.com',
          password: 'password123',
        );
        await tester.pump();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: authProvider),
              ChangeNotifierProvider.value(value: libraryProvider),
              ChangeNotifierProvider.value(value: readingProvider),
              ChangeNotifierProvider.value(value: novelProvider),
            ],
            child: const MaterialApp(home: ProfileScreen()),
          ),
        );

        await tester.pumpAndSettle();

        // Profile screen renders standard elements
        expect(find.text('Profile'), findsOneWidget);
        expect(find.text('Reading Preferences'), findsOneWidget);
        expect(find.text('Sign Out'), findsOneWidget);

        // Dev tools MUST NOT appear unless ENABLE_DEV_SEED is explicitly compiled in
        if (!AppConstants.enableDevSeed) {
          expect(find.text('Development Tools'), findsNothing);
          expect(find.text('Seed Demo Catalog'), findsNothing);
        }
      },
    );
  });
}
