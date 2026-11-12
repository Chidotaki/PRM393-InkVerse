import 'package:flutter_test/flutter_test.dart';
import 'package:inkverse/app/app.dart';
import 'package:inkverse/repositories/mock/mock_repositories.dart';

void main() {
  testWidgets('InkVerse initial launch smoke test', (
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
}
