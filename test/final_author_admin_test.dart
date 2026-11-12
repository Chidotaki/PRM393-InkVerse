import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkverse/app/app.dart';
import 'package:inkverse/app/router.dart';
import 'package:inkverse/core/errors/app_exception.dart';
import 'package:inkverse/models/models.dart';
import 'package:inkverse/providers/admin_provider.dart';
import 'package:inkverse/providers/auth_provider.dart';
import 'package:inkverse/providers/author_provider.dart';
import 'package:inkverse/providers/library_provider.dart';
import 'package:inkverse/providers/novel_provider.dart';
import 'package:inkverse/repositories/chapter_repository.dart';
import 'package:inkverse/repositories/mock/mock_repositories.dart';
import 'package:inkverse/screens/admin/admin_dashboard_screen.dart';
import 'package:inkverse/screens/author/author_dashboard_screen.dart';
import 'package:inkverse/screens/author/my_novels_screen.dart';
import 'package:inkverse/screens/reader/novel_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('Final Integration: Reader Regression & Author/Admin Modules', () {
    testWidgets(
      'NovelDetailScreen receives ChapterRepository from Provider tree without crashing',
      (WidgetTester tester) async {
        final mockNovel = MockNovelRepository();
        final mockChapter = MockChapterRepository(mockNovel);
        final mockLibrary = MockLibraryRepository(mockNovel);
        final mockAuth = MockAuthService(
          initialUserId: 'user_reader_1',
          initialUserEmail: 'reader@inkverse.com',
        );
        final mockUser = MockUserRepository();

        final authProvider = AuthProvider(
          authService: mockAuth,
          userRepository: mockUser,
        );
        final novelProvider = NovelProvider(novelRepository: mockNovel);
        final libraryProvider = LibraryProvider(libraryRepository: mockLibrary);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<ChapterRepository>.value(value: mockChapter),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<NovelProvider>.value(value: novelProvider),
              ChangeNotifierProvider<LibraryProvider>.value(
                value: libraryProvider,
              ),
            ],
            child: const MaterialApp(
              home: NovelDetailScreen(novelId: 'novel_1'),
            ),
          ),
        );

        // Pump frame
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Verify novel detail screen loaded without ProviderNotFoundException
        expect(find.byType(NovelDetailScreen), findsOneWidget);
        expect(find.text('The Last Star Keeper'), findsWidgets);
        expect(find.text('Start Reading'), findsOneWidget);
      },
    );

    testWidgets('AuthorDashboardScreen renders metrics and action buttons', (
      WidgetTester tester,
    ) async {
      final mockNovel = MockNovelRepository();
      final mockChapter = MockChapterRepository(mockNovel);
      final mockAuth = MockAuthService(
        initialUserId: 'user_author_1',
        initialUserEmail: 'author@inkverse.com',
      );
      final mockUser = MockUserRepository();

      final authProvider = AuthProvider(
        authService: mockAuth,
        userRepository: mockUser,
      );
      final authorProvider = AuthorProvider(
        novelRepository: mockNovel,
        chapterRepository: mockChapter,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<AuthorProvider>.value(value: authorProvider),
          ],
          child: const MaterialApp(home: AuthorDashboardScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Author Studio'), findsOneWidget);
      expect(find.text('New Novel'), findsOneWidget);
      expect(find.text('My Novels'), findsOneWidget);
      expect(find.text('Studio Overview'), findsOneWidget);
    });

    testWidgets('MyNovelsScreen renders filter chips and novel listing', (
      WidgetTester tester,
    ) async {
      final mockNovel = MockNovelRepository();
      final mockChapter = MockChapterRepository(mockNovel);
      final mockAuth = MockAuthService(
        initialUserId: 'user_author_1',
        initialUserEmail: 'author@inkverse.com',
      );
      final mockUser = MockUserRepository();

      final authProvider = AuthProvider(
        authService: mockAuth,
        userRepository: mockUser,
      );
      final authorProvider = AuthorProvider(
        novelRepository: mockNovel,
        chapterRepository: mockChapter,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<AuthorProvider>.value(value: authorProvider),
          ],
          child: const MaterialApp(home: MyNovelsScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Novels'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
      expect(find.text('Create Novel'), findsWidgets);
    });

    testWidgets('AdminDashboardScreen renders control modules and metrics', (
      WidgetTester tester,
    ) async {
      final mockUser = MockUserRepository();
      final mockNovel = MockNovelRepository();
      final mockReport = MockReportRepository();
      final mockGenre = MockGenreRepository();
      final mockComment = MockCommentRepository();
      final mockAuth = MockAuthService(
        initialUserId: 'user_admin_1',
        initialUserEmail: 'admin@inkverse.com',
      );

      final authProvider = AuthProvider(
        authService: mockAuth,
        userRepository: mockUser,
      );
      final adminProvider = AdminProvider(
        userRepository: mockUser,
        novelRepository: mockNovel,
        reportRepository: mockReport,
        genreRepository: mockGenre,
        commentRepository: mockComment,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<AdminProvider>.value(value: adminProvider),
          ],
          child: const MaterialApp(home: AdminDashboardScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Admin Control Center'), findsOneWidget);
      expect(find.text('User Management'), findsOneWidget);
      expect(find.text('Novel Moderation'), findsOneWidget);
      expect(find.text('Content Reports'), findsOneWidget);
      expect(find.text('Genre Taxonomy'), findsOneWidget);
    });

    test(
      'AdminProvider prevents administrator from disabling own account',
      () async {
        final mockUser = MockUserRepository();
        final mockNovel = MockNovelRepository();
        final mockReport = MockReportRepository();
        final mockGenre = MockGenreRepository();
        final mockComment = MockCommentRepository();

        final adminProvider = AdminProvider(
          userRepository: mockUser,
          novelRepository: mockNovel,
          reportRepository: mockReport,
          genreRepository: mockGenre,
          commentRepository: mockComment,
        );

        expect(
          () => adminProvider.setUserActive(
            uid: 'admin_123',
            isActive: false,
            currentAdminUid: 'admin_123',
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test('AppRoutes correctly generates author chapter edit path', () {
      expect(
        AppRoutes.authorChapterEditPath('nov_1', 'ch_5'),
        '/author/novel/nov_1/chapter/ch_5/edit',
      );
    });
  });
}
