import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkverse/app/app.dart';
import 'package:inkverse/app/shell/main_navigation_shell.dart';
import 'package:inkverse/repositories/mock/mock_repositories.dart';

void main() {
  testWidgets('InkVerse unauthenticated initial launch smoke test', (
    WidgetTester tester,
  ) async {
    final mockAuth = MockAuthService();
    final mockUser = MockUserRepository();
    final mockNovel = MockNovelRepository();
    final mockChapter = MockChapterRepository(mockNovel);
    final mockLibrary = MockLibraryRepository(mockNovel);
    final mockComment = MockCommentRepository();
    final mockReport = MockReportRepository();
    final mockGenre = MockGenreRepository();

    await tester.pumpWidget(
      InkVerseApp(
        authService: mockAuth,
        userRepository: mockUser,
        novelRepository: mockNovel,
        chapterRepository: mockChapter,
        libraryRepository: mockLibrary,
        commentRepository: mockComment,
        reportRepository: mockReport,
        genreRepository: mockGenre,
      ),
    );

    // Pump to process microtasks and auth initialization
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('InkVerse'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
  });

  testWidgets(
    'MainNavigationShell renders tabs and switches branch for reader',
    (WidgetTester tester) async {
      final mockAuth = MockAuthService(
        initialUserId: 'user_reader_1',
        initialUserEmail: 'reader@inkverse.com',
      );
      final mockUser = MockUserRepository();
      final mockNovel = MockNovelRepository();
      final mockChapter = MockChapterRepository(mockNovel);
      final mockLibrary = MockLibraryRepository(mockNovel);
      final mockComment = MockCommentRepository();
      final mockReport = MockReportRepository();
      final mockGenre = MockGenreRepository();

      await tester.pumpWidget(
        InkVerseApp(
          authService: mockAuth,
          userRepository: mockUser,
          novelRepository: mockNovel,
          chapterRepository: mockChapter,
          libraryRepository: mockLibrary,
          commentRepository: mockComment,
          reportRepository: mockReport,
          genreRepository: mockGenre,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify MainNavigationShell and NavigationBar are present
      expect(find.byType(MainNavigationShell), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Discover'), findsWidgets);
      expect(find.text('Library'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);

      // Initial tab is Home
      expect(find.text('Reader Home Screen'), findsWidgets);

      // Switch to Discover tab
      await tester.tap(find.text('Discover').last);
      await tester.pumpAndSettle();
      expect(find.text('Discover Novels'), findsWidgets);

      // Switch to Library tab
      await tester.tap(find.text('Library').last);
      await tester.pumpAndSettle();
      expect(find.text('My Library'), findsWidgets);

      // Switch to Profile tab
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      expect(find.text('User Profile Screen'), findsWidgets);
    },
  );
}
