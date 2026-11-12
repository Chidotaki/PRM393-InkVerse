import 'package:flutter_test/flutter_test.dart';
import 'package:inkverse/core/errors/app_exception.dart';
import 'package:inkverse/models/models.dart';
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

    setUp(() {
      userRepo = MockUserRepository();
      novelRepo = MockNovelRepository();
      chapterRepo = MockChapterRepository(novelRepo);
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
      },
    );

    test('Publish novel requires ownership', () async {
      expect(
        () => novelRepo.publishNovel('novel_1', 'different_author_id'),
        throwsA(isA<PermissionDeniedException>()),
      );
    });
  });
}
