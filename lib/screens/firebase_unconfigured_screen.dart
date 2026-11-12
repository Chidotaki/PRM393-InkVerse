import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/theme.dart';
import '../core/utils/responsive.dart';
import '../repositories/repositories.dart';

/// Screen displayed when the application is started in Production/Firebase mode
/// but Firebase platform configuration has not yet been provisioned.
class FirebaseUnconfiguredScreen extends StatelessWidget {
  final String errorDetails;

  const FirebaseUnconfiguredScreen({super.key, required this.errorDetails});

  void _launchMockBackend(BuildContext context) {
    final mockAuth = MockAuthService();
    final mockUser = MockUserRepository();
    final mockNovel = MockNovelRepository();
    final mockChapter = MockChapterRepository(mockNovel);
    final mockLibrary = MockLibraryRepository(mockNovel);
    final mockComment = MockCommentRepository();
    final mockReport = MockReportRepository();
    final mockGenre = MockGenreRepository();

    runApp(
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InkVerse - Setup Required',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Responsive.constrained(
              maxWidth: 540,
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Firebase Configuration Required',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'InkVerse is running in Production Backend mode, but Google Firebase platform credentials were not found.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Error Details:\n$errorDetails',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'How to Resolve:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1. For immediate UI testing without Firebase credentials, run with:\n'
                        '   flutter run -d chrome --dart-define=USE_MOCK_BACKEND=true\n\n'
                        '2. To connect to Cloud Firebase:\n'
                        '   Follow the step-by-step instructions in FIREBASE_SETUP.md.',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text(
                          'Proceed with Development Mock Backend',
                        ),
                        onPressed: () => _launchMockBackend(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
