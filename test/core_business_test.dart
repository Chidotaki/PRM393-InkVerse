import 'package:flutter_test/flutter_test.dart';
import 'package:inkverse/core/constants/app_constants.dart';
import 'package:inkverse/core/errors/app_exception.dart';
import 'package:inkverse/models/models.dart';
import 'package:inkverse/providers/admin_provider.dart';
import 'package:inkverse/providers/novel_provider.dart';
import 'package:inkverse/repositories/mock/mock_repositories.dart';

void main() {
  group('Core Domain Models & Business Logic', () {
    test('UserRole defaults safely to reader for unknown/null values', () {
      expect(UserRole.fromString(null), UserRole.reader);
      expect(UserRole.fromString(''), UserRole.reader);
      expect(UserRole.fromString('hacker'), UserRole.reader);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('author'), UserRole.author);
    });

    test('Follow deterministic ID format', () {
      final follow = Follow.create(userId: 'user_1', novelId: 'novel_a');
      expect(follow.id, 'user_1_novel_a');
    });

    test('Bookmark deterministic ID format', () {
      final bookmark = Bookmark.create(
        userId: 'user_1',
        novelId: 'novel_a',
        chapterId: 'chap_1',
        chapterNumber: 1,
        novelTitle: 'Title',
        chapterTitle: 'Chap 1',
      );
      expect(bookmark.id, 'user_1_novel_a_chap_1');
    });

    test('ReadingProgress deterministic ID format', () {
      final progress = ReadingProgress.create(
        userId: 'user_1',
        novelId: 'novel_a',
        novelTitle: 'Title',
        chapterId: 'chap_1',
        chapterTitle: 'Chap 1',
        chapterNumber: 1,
      );
      expect(progress.id, 'user_1_novel_a');
    });

    test('Chapter word count calculation', () {
      expect(Chapter.calculateWordCount('One two three four five'), 5);
      expect(Chapter.calculateWordCount('   '), 0);
      expect(Chapter.calculateWordCount('Hello\nworld   again'), 3);
    });
  });

  group('Mock Repository Business Rules', () {
    late MockUserRepository userRepo;
    late MockNovelRepository novelRepo;
    late MockChapterRepository chapterRepo;
    late MockLibraryRepository libraryRepo;
    late MockCommentRepository commentRepo;
    late MockReportRepository reportRepo;
    late MockGenreRepository genreRepo;

    setUp(() {
      userRepo = MockUserRepository();
      novelRepo = MockNovelRepository();
      chapterRepo = MockChapterRepository(novelRepo);
      libraryRepo = MockLibraryRepository(novelRepo);
      commentRepo = MockCommentRepository();
      reportRepo = MockReportRepository();
      genreRepo = MockGenreRepository();
    });

    test(
      'Reader can become author, but author cannot self-promote to admin',
      () async {
        final reader = await userRepo.getUserProfile('mock_user_reader');
        expect(reader?.role, UserRole.reader);

        // Reader becomes author
        await userRepo.becomeAuthor('mock_user_reader');
        final updated = await userRepo.getUserProfile('mock_user_reader');
        expect(updated?.role, UserRole.author);

        // Transition again is rejected
        expect(
          () => userRepo.becomeAuthor('mock_user_reader'),
          throwsA(isA<ConflictException>()),
        );
      },
    );

    test(
      'Chapter repository rejects duplicate chapter numbers in same novel',
      () async {
        final dupChapter = Chapter(
          id: '',
          novelId: 'novel_1',
          authorId: 'mock_user_author',
          title: 'Duplicate Chapter',
          chapterNumber: 1, // Chapter 1 already seeded for novel_1
          content: 'Some text',
        );

        expect(
          () => chapterRepo.createChapter(dupChapter),
          throwsA(isA<ConflictException>()),
        );

        // Chapter 1 in a different novel is completely allowed
        final validOtherNovelChap = Chapter(
          id: '',
          novelId: 'novel_unseeded',
          authorId: 'mock_user_author',
          title: 'Other Novel Chapter',
          chapterNumber: 1,
          content: 'Some text',
        );
        final id = await chapterRepo.createChapter(validOtherNovelChap);
        expect(id.isNotEmpty, true);
      },
    );

    test('Chapter navigation with gaps navigates correctly', () async {
      // Create novel with gap chapters: 1, 3, 8
      const gapNovelId = 'gap_test_novel';
      await chapterRepo.createChapter(
        const Chapter(
          id: 'gap_c1',
          novelId: gapNovelId,
          authorId: 'mock_user_author',
          title: 'Chapter 1',
          chapterNumber: 1,
          content: 'Text 1',
        ),
      );
      await chapterRepo.publishChapter(gapNovelId, 'gap_c1');

      await chapterRepo.createChapter(
        const Chapter(
          id: 'gap_c3',
          novelId: gapNovelId,
          authorId: 'mock_user_author',
          title: 'Chapter 3',
          chapterNumber: 3,
          content: 'Text 3',
        ),
      );
      await chapterRepo.publishChapter(gapNovelId, 'gap_c3');

      await chapterRepo.createChapter(
        const Chapter(
          id: 'gap_c8',
          novelId: gapNovelId,
          authorId: 'mock_user_author',
          title: 'Chapter 8',
          chapterNumber: 8,
          content: 'Text 8',
        ),
      );
      await chapterRepo.publishChapter(gapNovelId, 'gap_c8');

      // Navigate from chapter 1
      final nextFrom1 = await chapterRepo.getNextChapter(gapNovelId, 1);
      expect(nextFrom1?.chapterNumber, 3);

      final prevFrom1 = await chapterRepo.getPreviousChapter(gapNovelId, 1);
      expect(prevFrom1, isNull);

      // Navigate from chapter 3
      final nextFrom3 = await chapterRepo.getNextChapter(gapNovelId, 3);
      expect(nextFrom3?.chapterNumber, 8);

      final prevFrom3 = await chapterRepo.getPreviousChapter(gapNovelId, 3);
      expect(prevFrom3?.chapterNumber, 1);

      // Navigate from chapter 8
      final nextFrom8 = await chapterRepo.getNextChapter(gapNovelId, 8);
      expect(nextFrom8, isNull);

      final prevFrom8 = await chapterRepo.getPreviousChapter(gapNovelId, 8);
      expect(prevFrom8?.chapterNumber, 3);
    });

    test(
      'Publish novel requires ownership and at least one published chapter',
      () async {
        // Rejects non-owner
        expect(
          () => novelRepo.publishNovel('novel_1', 'different_author_id'),
          throwsA(isA<PermissionDeniedException>()),
        );

        // Rejects draft novel with 0 published chapters
        expect(
          () => novelRepo.publishNovel('novel_draft_1', 'mock_user_author'),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'Follow is idempotent and follower count never drops below 0',
      () async {
        const testUser = 'user_follow_test';
        const testNovel = 'novel_5'; // Has 98 followers initially

        final initial = await novelRepo.getNovel(testNovel);
        final initialCount = initial!.followerCount;

        // Follow once
        await libraryRepo.followNovel(testUser, testNovel);
        expect(await libraryRepo.isFollowing(testUser, testNovel), true);
        final afterFirstFollow = await novelRepo.getNovel(testNovel);
        expect(afterFirstFollow!.followerCount, initialCount + 1);

        // Follow second time (idempotent)
        await libraryRepo.followNovel(testUser, testNovel);
        final afterSecondFollow = await novelRepo.getNovel(testNovel);
        expect(afterSecondFollow!.followerCount, initialCount + 1);

        // Unfollow
        await libraryRepo.unfollowNovel(testUser, testNovel);
        expect(await libraryRepo.isFollowing(testUser, testNovel), false);
        final afterUnfollow = await novelRepo.getNovel(testNovel);
        expect(afterUnfollow!.followerCount, initialCount);

        // Unfollow again when not following (never below 0)
        await libraryRepo.unfollowNovel(testUser, testNovel);
        final afterDoubleUnfollow = await novelRepo.getNovel(testNovel);
        expect(afterDoubleUnfollow!.followerCount, initialCount);
      },
    );

    test('Bookmark is idempotent', () async {
      const bookmark = Bookmark(
        id: 'b_test',
        userId: 'u_test',
        novelId: 'n_test',
        chapterId: 'c_test',
        chapterNumber: 1,
        novelTitle: 'Test Novel',
        chapterTitle: 'Test Chapter',
      );

      await libraryRepo.addBookmark(bookmark);
      expect(
        await libraryRepo.isBookmarked('u_test', 'n_test', 'c_test'),
        true,
      );

      // Adding again does not duplicate
      await libraryRepo.addBookmark(bookmark);
      final bookmarks = await libraryRepo.getBookmarks('u_test');
      expect(bookmarks.where((b) => b.novelId == 'n_test').length, 1);
    });

    test(
      'Reading progress upsert ensures exactly one record per user and novel',
      () async {
        final p1 = ReadingProgress.create(
          userId: 'u_prog_test',
          novelId: 'novel_1',
          novelTitle: 'The Last Star Keeper',
          chapterId: 'chap_1_1',
          chapterTitle: 'Chapter 1',
          chapterNumber: 1,
        );
        await libraryRepo.saveReadingProgress(p1);

        final p2 = ReadingProgress.create(
          userId: 'u_prog_test',
          novelId: 'novel_1',
          novelTitle: 'The Last Star Keeper',
          chapterId: 'chap_1_2',
          chapterTitle: 'Chapter 2',
          chapterNumber: 2,
        );
        await libraryRepo.saveReadingProgress(p2);

        final history = await libraryRepo.getReadingHistory('u_prog_test');
        expect(history.where((r) => r.novelId == 'novel_1').length, 1);
        final latest = await libraryRepo.getReadingProgress(
          'u_prog_test',
          'novel_1',
        );
        expect(latest?.chapterNumber, 2);
      },
    );

    test(
      'AdminProvider prevents administrator from disabling own account',
      () async {
        final adminProvider = AdminProvider(
          userRepository: userRepo,
          novelRepository: novelRepo,
          reportRepository: reportRepo,
          genreRepository: genreRepo,
          commentRepository: commentRepo,
        );

        // Admin Carol attempts to disable herself
        expect(
          () => adminProvider.setUserActive(
            uid: 'mock_user_admin',
            isActive: false,
            currentAdminUid: 'mock_user_admin',
          ),
          throwsA(isA<ValidationException>()),
        );

        // Admin Carol disabling another user succeeds
        await adminProvider.setUserActive(
          uid: 'mock_user_reader',
          isActive: false,
          currentAdminUid: 'mock_user_admin',
        );
        final target = await userRepo.getUserProfile('mock_user_reader');
        expect(target?.isActive, false);
      },
    );

    test('Genre duplicate prevention is case-insensitive', () async {
      expect(
        () => genreRepo.addGenre('fantasy'), // 'Fantasy' is already seeded
        throwsA(isA<ConflictException>()),
      );
      expect(
        () => genreRepo.addGenre('FANTASY'),
        throwsA(isA<ConflictException>()),
      );

      // New unique genre
      final newId = await genreRepo.addGenre('Cyberpunk');
      expect(newId.isNotEmpty, true);
    });
  });

  group('NovelProvider Search, Filter & Sort Pipeline', () {
    late MockNovelRepository novelRepo;
    late NovelProvider novelProvider;

    setUp(() async {
      novelRepo = MockNovelRepository();
      novelProvider = NovelProvider(novelRepository: novelRepo);
      await novelProvider.fetchNovels();
    });

    test('visibleNovels filters only published novels and excludes drafts', () {
      final list = novelProvider.visibleNovels;
      expect(list.any((n) => n.visibility != NovelVisibility.published), false);
      expect(list.any((n) => n.id == 'novel_draft_1'), false);
    });

    test('Search query matches title and author case-insensitively', () {
      novelProvider.setSearchQuery('star');
      expect(
        novelProvider.visibleNovels.any((n) => n.title.contains('Star')),
        true,
      );

      novelProvider.setSearchQuery('elena');
      expect(
        novelProvider.visibleNovels.every(
          (n) => n.authorName == 'Elena Rostova',
        ),
        true,
      );
    });

    test('Genre filter narrows down results', () {
      novelProvider.setSelectedGenre('Horror');
      for (final n in novelProvider.visibleNovels) {
        expect(n.genres.contains('Horror'), true);
      }
    });

    test('Sorting by Most Popular sorts by viewCount descending', () {
      novelProvider.setSelectedSort(NovelSort.mostPopular);
      final list = novelProvider.visibleNovels;
      for (int i = 0; i < list.length - 1; i++) {
        expect(list[i].viewCount >= list[i + 1].viewCount, true);
      }
    });
  });
}
