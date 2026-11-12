import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/utils/dev_seeder.dart';
import 'repositories/repositories.dart';
import 'screens/firebase_unconfigured_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

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
  String? firebaseInitError;

  // 1. In mock backend mode, DO NOT call Firebase.initializeApp()
  if (!forceMockBackend) {
    try {
      // Attempts initialization if platform configuration (google-services.json / GoogleService-Info.plist) exists
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
      if (kDebugMode) {
        debugPrint('[InkVerse] Connected to Cloud Firebase successfully.');
      }
    } catch (e) {
      firebaseInitError = e.toString();
      if (kDebugMode) {
        debugPrint(
          '[InkVerse] Firebase not yet configured or failed to initialize: $e\n'
          '[InkVerse] To configure Firebase, follow FIREBASE_SETUP.md.\n'
          '[InkVerse] To run with offline mock backend, use: --dart-define=USE_MOCK_BACKEND=true',
        );
      }
      firebaseInitialized = false;
    }
  } else {
    if (kDebugMode) {
      debugPrint(
        '[InkVerse] USE_MOCK_BACKEND=true: Launching with in-memory mock suite.',
      );
    }
  }

  // 2. Production mode without Firebase credentials -> show clear startup screen
  if (!forceMockBackend && !firebaseInitialized) {
    runApp(
      FirebaseUnconfiguredScreen(
        errorDetails: firebaseInitError ?? 'Firebase credentials not found. Run flutterfire configure or see FIREBASE_SETUP.md.',
      ),
    );
    return;
  }

  // 3. Launch with Cloud Firebase Backend
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
      await DevSeeder.seedIfEmpty(FirebaseFirestore.instance);
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
    // 4. Launch with Development Mock Backend
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
