import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/author_provider.dart';
import '../providers/library_provider.dart';
import '../providers/novel_provider.dart';
import '../providers/reading_provider.dart';
import '../providers/social_provider.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/comment_repository.dart';
import '../repositories/genre_repository.dart';
import '../repositories/library_repository.dart';
import '../repositories/novel_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import 'router.dart';
import 'theme.dart';

/// Root application widget that wires dependencies, multi-providers,
/// routing, and theme configuration.
class InkVerseApp extends StatefulWidget {
  final AuthService authService;
  final UserRepository userRepository;
  final NovelRepository novelRepository;
  final ChapterRepository chapterRepository;
  final LibraryRepository libraryRepository;
  final CommentRepository commentRepository;
  final ReportRepository reportRepository;
  final GenreRepository genreRepository;

  const InkVerseApp({
    super.key,
    required this.authService,
    required this.userRepository,
    required this.novelRepository,
    required this.chapterRepository,
    required this.libraryRepository,
    required this.commentRepository,
    required this.reportRepository,
    required this.genreRepository,
  });

  @override
  State<InkVerseApp> createState() => _InkVerseAppState();
}

class _InkVerseAppState extends State<InkVerseApp> {
  late final AuthProvider _authProvider;
  late final NovelProvider _novelProvider;
  late final LibraryProvider _libraryProvider;
  late final ReadingProvider _readingProvider;
  late final AuthorProvider _authorProvider;
  late final SocialProvider _socialProvider;
  late final AdminProvider _adminProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(
      authService: widget.authService,
      userRepository: widget.userRepository,
    );

    _novelProvider = NovelProvider(novelRepository: widget.novelRepository);

    _libraryProvider = LibraryProvider(
      libraryRepository: widget.libraryRepository,
    );

    _readingProvider = ReadingProvider(
      chapterRepository: widget.chapterRepository,
      libraryRepository: widget.libraryRepository,
    );

    _authorProvider = AuthorProvider(
      novelRepository: widget.novelRepository,
      chapterRepository: widget.chapterRepository,
    );

    _socialProvider = SocialProvider(
      commentRepository: widget.commentRepository,
      reportRepository: widget.reportRepository,
    );

    _adminProvider = AdminProvider(
      userRepository: widget.userRepository,
      novelRepository: widget.novelRepository,
      reportRepository: widget.reportRepository,
      genreRepository: widget.genreRepository,
      commentRepository: widget.commentRepository,
    );

    _router = createRouter(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _novelProvider.dispose();
    _libraryProvider.dispose();
    _readingProvider.dispose();
    _authorProvider.dispose();
    _socialProvider.dispose();
    _adminProvider.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<NovelProvider>.value(value: _novelProvider),
        ChangeNotifierProvider<LibraryProvider>.value(value: _libraryProvider),
        ChangeNotifierProvider<ReadingProvider>.value(value: _readingProvider),
        ChangeNotifierProvider<AuthorProvider>.value(value: _authorProvider),
        ChangeNotifierProvider<SocialProvider>.value(value: _socialProvider),
        ChangeNotifierProvider<AdminProvider>.value(value: _adminProvider),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
