import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkverse/app/app.dart';
import 'package:inkverse/repositories/mock/mock_repositories.dart';

Widget _createTestApp(MockAuthService auth) {
  final user = MockUserRepository();
  final novel = MockNovelRepository();
  final chapter = MockChapterRepository(novel);
  final library = MockLibraryRepository(novel);
  final comment = MockCommentRepository();
  final report = MockReportRepository();
  final genre = MockGenreRepository();

  return InkVerseApp(
    authService: auth,
    userRepository: user,
    novelRepository: novel,
    chapterRepository: chapter,
    libraryRepository: library,
    commentRepository: comment,
    reportRepository: report,
    genreRepository: genre,
  );
}

void main() {
  group('Phase 4 Role-Based Route Guards & Redirects', () {
    testWidgets('Unauthenticated user on launch lands at /login', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockAuthService(); // unauthenticated

      await tester.pumpWidget(_createTestApp(mockAuth));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('InkVerse'), findsOneWidget);
    });

    testWidgets('Disabled user on launch lands at /account-disabled', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockAuthService(
        initialUserId: 'mock_user_disabled',
        initialUserEmail: 'disabled@inkverse.com',
      );

      await tester.pumpWidget(_createTestApp(mockAuth));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Account Suspended'), findsOneWidget);
    });

    testWidgets('Reader on launch lands at /home in MainNavigationShell', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockAuthService(
        initialUserId: 'mock_user_reader',
        initialUserEmail: 'reader@inkverse.com',
      );

      await tester.pumpWidget(_createTestApp(mockAuth));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Trending Now'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('Author on launch has Author Studio shortcut visible', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockAuthService(
        initialUserId: 'mock_user_author',
        initialUserEmail: 'author@inkverse.com',
      );

      await tester.pumpWidget(_createTestApp(mockAuth));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Author Studio'), findsWidgets);
      expect(find.text('Author Mode Active'), findsOneWidget);
    });

    testWidgets('Admin on launch lands at /admin Admin Control Center', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockAuthService(
        initialUserId: 'mock_user_admin',
        initialUserEmail: 'admin@inkverse.com',
      );

      await tester.pumpWidget(_createTestApp(mockAuth));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Admin Control Center'), findsWidgets);
    });
  });
}
