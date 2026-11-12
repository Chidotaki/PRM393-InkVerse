import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../models/bookmark.dart';
import '../../models/chapter.dart';
import '../../models/novel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/novel_provider.dart';
import '../../providers/reading_provider.dart';
import '../../providers/social_provider.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';

/// Immersive, customizable chapter reading interface featuring typography controls,
/// theme switching (Light / Dark / Sepia), bookmarking, chapter navigation, and reader comments.
class ReadingScreen extends StatefulWidget {
  final String novelId;
  final String chapterId;

  const ReadingScreen({
    super.key,
    required this.novelId,
    required this.chapterId,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  Novel? _novel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadChapterData();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapterId != widget.chapterId ||
        oldWidget.novelId != widget.novelId) {
      _loadChapterData();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChapterData() async {
    final auth = context.read<AuthProvider>();
    final novelProvider = context.read<NovelProvider>();
    final readingProvider = context.read<ReadingProvider>();

    _novel = await novelProvider.getNovelById(widget.novelId);

    if (mounted) {
      await readingProvider.loadChapter(
        novelId: widget.novelId,
        chapterId: widget.chapterId,
        userId: auth.currentUid,
        novel: _novel,
      );
    }
  }

  _ThemeColors _getThemeColors(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'sepia':
        return const _ThemeColors(
          background: Color(0xFFFBF0D9),
          surface: Color(0xFFF4E5C3),
          text: Color(0xFF2C2416),
          muted: Color(0xFF70634E),
          appBarBg: Color(0xFFF4E5C3),
          appBarFg: Color(0xFF2C2416),
          border: Color(0xFFE2D1A8),
        );
      case 'light':
        return const _ThemeColors(
          background: Color(0xFFFAFAFA),
          surface: Color(0xFFFFFFFF),
          text: Color(0xFF1E293B),
          muted: Color(0xFF64748B),
          appBarBg: Color(0xFFFFFFFF),
          appBarFg: Color(0xFF0F172A),
          border: Color(0xFFE2E8F0),
        );
      case 'dark':
      default:
        return const _ThemeColors(
          background: Color(0xFF0F172A),
          surface: Color(0xFF1E293B),
          text: Color(0xFFE2E8F0),
          muted: Color(0xFF94A3B8),
          appBarBg: Color(0xFF1E293B),
          appBarFg: Color(0xFFF1F5F9),
          border: Color(0xFF334155),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reading = context.watch<ReadingProvider>();
    final library = context.watch<LibraryProvider>();
    final auth = context.watch<AuthProvider>();

    final themeColors = _getThemeColors(reading.readingTheme);
    final isBookmarked = library.isBookmarked(widget.novelId, widget.chapterId);
    final chapter = reading.currentChapter;

    if (reading.loading && chapter == null) {
      return Scaffold(
        backgroundColor: themeColors.background,
        appBar: AppBar(
          backgroundColor: themeColors.appBarBg,
          foregroundColor: themeColors.appBarFg,
          title: Text(_novel?.title ?? 'Reading'),
        ),
        body: const LoadingState(message: 'Opening chapter...'),
      );
    }

    if (reading.error != null && chapter == null) {
      return Scaffold(
        backgroundColor: themeColors.background,
        appBar: AppBar(
          backgroundColor: themeColors.appBarBg,
          foregroundColor: themeColors.appBarFg,
          title: const Text('Error'),
        ),
        body: ErrorState(message: reading.error!, onRetry: _loadChapterData),
      );
    }

    if (chapter == null) {
      return Scaffold(
        backgroundColor: themeColors.background,
        appBar: AppBar(
          backgroundColor: themeColors.appBarBg,
          foregroundColor: themeColors.appBarFg,
          title: const Text('Chapter Not Found'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Return to Novel'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeColors.background,
      appBar: AppBar(
        backgroundColor: themeColors.appBarBg,
        foregroundColor: themeColors.appBarFg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _novel?.title ?? 'InkVerse',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Chapter ${chapter.chapterNumber}: ${chapter.title}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // Bookmark action
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amber : null,
            ),
            tooltip: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
            onPressed: () async {
              final uid = auth.currentUid;
              if (uid != null) {
                if (isBookmarked) {
                  await library.removeBookmark(
                    uid,
                    widget.novelId,
                    widget.chapterId,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bookmark removed.')),
                    );
                  }
                } else {
                  final bm = Bookmark.create(
                    userId: uid,
                    novelId: widget.novelId,
                    novelTitle: _novel?.title ?? 'Novel',
                    chapterId: chapter.id,
                    chapterTitle: chapter.title,
                    chapterNumber: chapter.chapterNumber,
                  );
                  await library.addBookmark(bm);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chapter bookmarked!')),
                    );
                  }
                }
              }
            },
          ),

          // Chapter Comments
          IconButton(
            icon: const Icon(Icons.mode_comment_outlined),
            tooltip: 'Chapter Comments',
            onPressed: () => _showCommentsSheet(context, chapter),
          ),

          // Reading Settings Sheet
          IconButton(
            icon: const Icon(Icons.format_size),
            tooltip: 'Reading Preferences',
            onPressed: () => _showSettingsSheet(context, reading, themeColors),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chapter Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: themeColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: themeColors.border),
                        ),
                        child: Text(
                          'CHAPTER ${chapter.chapterNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: themeColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        chapter.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: reading.fontSize + 6,
                          fontWeight: FontWeight.bold,
                          color: themeColors.text,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${chapter.wordCount} words',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeColors.muted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: themeColors.border),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Chapter Story Content
                SelectableText(
                  chapter.content,
                  style: TextStyle(
                    fontSize: reading.fontSize,
                    height: reading.lineSpacing,
                    color: themeColors.text,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 48),
                Divider(color: themeColors.border),
                const SizedBox(height: 24),

                // Bottom Chapter Navigation Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (reading.hasPreviousChapter)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: themeColors.text,
                          side: BorderSide(color: themeColors.border),
                        ),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Previous Chapter'),
                        onPressed: () async {
                          final prev = await reading.goToPreviousChapter(
                            userId: auth.currentUid,
                            novel: _novel,
                          );
                          if (prev != null && context.mounted) {
                            context.go(
                              AppRoutes.readingPath(widget.novelId, prev.id),
                            );
                          }
                        },
                      )
                    else
                      const SizedBox.shrink(),
                    if (reading.hasNextChapter)
                      FilledButton.icon(
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Next Chapter'),
                        onPressed: () async {
                          final next = await reading.goToNextChapter(
                            userId: auth.currentUid,
                            novel: _novel,
                          );
                          if (next != null && context.mounted) {
                            context.go(
                              AppRoutes.readingPath(widget.novelId, next.id),
                            );
                          }
                        },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: themeColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Latest Chapter Reached',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeColors.muted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(
    BuildContext context,
    ReadingProvider reading,
    _ThemeColors themeColors,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: themeColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reading Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeColors.text,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reading Theme Selection
                  Text(
                    'THEME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: themeColors.muted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildThemeOption(
                        reading,
                        'dark',
                        'Dark',
                        const Color(0xFF0F172A),
                        const Color(0xFFF1F5F9),
                        setSheetState,
                      ),
                      const SizedBox(width: 10),
                      _buildThemeOption(
                        reading,
                        'sepia',
                        'Sepia',
                        const Color(0xFFFBF0D9),
                        const Color(0xFF2C2416),
                        setSheetState,
                      ),
                      const SizedBox(width: 10),
                      _buildThemeOption(
                        reading,
                        'light',
                        'Light',
                        const Color(0xFFFFFFFF),
                        const Color(0xFF0F172A),
                        setSheetState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Font Size Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FONT SIZE (${reading.fontSize.toInt()}pt)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: themeColors.muted,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            color: themeColors.text,
                            onPressed: () {
                              final newSize = (reading.fontSize - 1).clamp(
                                12.0,
                                32.0,
                              );
                              reading.setFontSize(newSize);
                              setSheetState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            color: themeColors.text,
                            onPressed: () {
                              final newSize = (reading.fontSize + 1).clamp(
                                12.0,
                                32.0,
                              );
                              reading.setFontSize(newSize);
                              setSheetState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Slider(
                    value: reading.fontSize,
                    min: 12.0,
                    max: 32.0,
                    divisions: 20,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) {
                      reading.setFontSize(val);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  // Line Spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LINE SPACING (${reading.lineSpacing.toStringAsFixed(1)})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: themeColors.muted,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_line_spacing),
                            color: themeColors.text,
                            onPressed: () {
                              final newSpacing = reading.lineSpacing >= 2.2
                                  ? 1.4
                                  : reading.lineSpacing + 0.2;
                              reading.setLineSpacing(newSpacing);
                              setSheetState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    ReadingProvider reading,
    String themeKey,
    String label,
    Color bg,
    Color fg,
    StateSetter setSheetState,
  ) {
    final isSelected = reading.readingTheme == themeKey;

    return Expanded(
      child: InkWell(
        onTap: () {
          reading.setReadingTheme(themeKey);
          setSheetState(() {});
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.tealAccent : Colors.grey.shade600,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, Chapter chapter) {
    final social = context.read<SocialProvider>();
    final auth = context.read<AuthProvider>();
    final commentController = TextEditingController();

    social.loadComments(chapter.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 480,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Comments (Chapter ${chapter.chapterNumber})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Consumer<SocialProvider>(
                    builder: (context, social, _) {
                      if (social.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (social.comments.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_outlined,
                                size: 36,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 8),
                              const Text('No comments yet on this chapter.'),
                              const Text(
                                'Be the first to share your thoughts!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: social.comments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = social.comments[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      child: Text(
                                        c.userName.isNotEmpty
                                            ? c.userName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      c.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c.content,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a respectful comment...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.send, size: 18),
                        onPressed: () async {
                          final text = commentController.text.trim();
                          if (text.isNotEmpty && auth.currentUid != null) {
                            await social.addComment(
                              userId: auth.currentUid!,
                              userName: auth.currentUser?.fullName ?? 'Reader',
                              novelId: widget.novelId,
                              chapterId: chapter.id,
                              content: text,
                            );
                            commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeColors {
  final Color background;
  final Color surface;
  final Color text;
  final Color muted;
  final Color appBarBg;
  final Color appBarFg;
  final Color border;

  const _ThemeColors({
    required this.background,
    required this.surface,
    required this.text,
    required this.muted,
    required this.appBarBg,
    required this.appBarFg,
    required this.border,
  });
}
