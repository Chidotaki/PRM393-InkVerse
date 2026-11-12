import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'repositories/repositories.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const bool forceMockBackend = bool.fromEnvironment(
    'USE_MOCK_BACKEND',
    defaultValue: false,
  );

  const bool enableDevSeed = bool.fromEnvironment(
    'ENABLE_DEV_SEED',
    defaultValue: false,
  );

  bool firebaseInitialized = false;

  if (!forceMockBackend) {
    try {
      // Attempts initialization if platform configuration (google-services.json / GoogleService-Info.plist) exists
      await Firebase.initializeApp();
      firebaseInitialized = true;
      if (kDebugMode) {
        print('[InkVerse] Connected to Cloud Firebase successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '[InkVerse] Firebase not yet configured or failed to initialize ($e).\n'
          '[InkVerse] Falling back to development mock backend.\n'
          '[InkVerse] To configure Firebase, follow FIREBASE_SETUP.md.',
        );
      }
      firebaseInitialized = false;
    }
  } else {
    if (kDebugMode) {
      print(
        '[InkVerse] USE_MOCK_BACKEND=true: Launching with in-memory mock suite.',
      );
    }
  }

  // Choose between Firebase or Mock In-Memory backend
  if (firebaseInitialized) {
    final authService = FirebaseAuthService();
    final userRepo = FirebaseUserRepository();
    final novelRepo = FirebaseNovelRepository();
    final chapterRepo = FirebaseChapterRepository();
    final libraryRepo = FirebaseLibraryRepository();
    final commentRepo = FirebaseCommentRepository();
    final reportRepo = FirebaseReportRepository();
    final genreRepo = FirebaseGenreRepository();

    if (enableDevSeed) {
      // Optional development seed per Section 51
      await genreRepo.seedDefaultGenres();
    }

    runApp(
      InkVerseApp(
        authService: authService,
        userRepository: userRepo,
        novelRepository: novelRepo,
        chapterRepository: chapterRepo,
        libraryRepository: libraryRepo,
        commentRepository: commentRepo,
        reportRepository: reportRepo,
        genreRepository: genreRepo,
      ),
    );
  } else {
    // Development Mock Backend Suite
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
}
