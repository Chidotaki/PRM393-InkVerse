import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/utils/date_time_util.dart';
import '../../models/chapter.dart';
import '../../models/novel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/novel_provider.dart';
import '../../repositories/chapter_repository.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/novel_cover.dart';
import '../../widgets/status_chip.dart';

/// Detailed view of a serialized novel including synopsis, metrics,
/// follow toggle, and full published chapter index.
class NovelDetailScreen extends StatefulWidget {
  final String novelId;

  const NovelDetailScreen({super.key, required this.novelId});

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  Novel? _novel;
  List<Chapter> _chapters = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final novelProvider = context.read<NovelProvider>();
      final chapterRepo = context.read<ChapterRepository>();

      final results = await Future.wait([
        novelProvider.getNovelById(widget.novelId),
        chapterRepo.getPublishedChapters(widget.novelId),
      ]);

      if (mounted) {
        setState(() {
          _novel = results[0] as Novel?;
          _chapters = results[1] as List<Chapter>;
          _loading = false;
        });

        // Record a view for analytics
        if (_novel != null) {
          novelProvider.recordView(widget.novelId);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final libraryProvider = context.watch<LibraryProvider>();
    final authProvider = context.watch<AuthProvider>();

    final isFollowing = libraryProvider.isFollowing(widget.novelId);

    // Check if user has reading progress for this novel
    final userProgress = libraryProvider.readingHistory.where(
      (p) => p.novelId == widget.novelId,
    );
    final activeProgress = userProgress.isNotEmpty ? userProgress.first : null;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Novel Details')),
        body: const LoadingState(message: 'Loading novel details...'),
      );
    }

    if (_novel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                _error != null
                    ? 'Failed to load novel: $_error'
                    : 'Novel not found or is currently unavailable.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final novel = _novel!;

    // Sort chapters ascending
    final sortedChapters = List<Chapter>.from(_chapters)
      ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text(novel.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              isFollowing ? Icons.bookmark : Icons.bookmark_border,
              color: isFollowing ? colorScheme.primary : null,
            ),
            tooltip: isFollowing ? 'Unfollow' : 'Follow Novel',
            onPressed: () async {
              final uid = authProvider.currentUid;
              if (uid != null) {
                await libraryProvider.toggleFollow(uid, novel.id);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header Card
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NovelCover(
                      title: novel.title,
                      authorName: novel.authorName,
                      coverUrl: novel.coverUrl,
                      genres: novel.genres,
                      width: 120,
                      height: 174,
                      borderRadius: 10,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusChip(status: novel.status),
                          const SizedBox(height: 8),
                          Text(
                            novel.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Written by ${novel.authorName}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Quick metrics
                          Row(
                            children: [
                              _buildMetric(
                                context,
                                Icons.menu_book,
                                '${novel.chapterCount}',
                                'Chapters',
                              ),
                              const SizedBox(width: 14),
                              _buildMetric(
                                context,
                                Icons.people_outline,
                                _formatNumber(novel.followerCount),
                                'Followers',
                              ),
                              const SizedBox(width: 14),
                              _buildMetric(
                                context,
                                Icons.visibility_outlined,
                                _formatNumber(novel.viewCount),
                                'Views',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Genres Wrap
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: novel.genres
                                .map((g) => GenreChip(label: g, compact: true))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Primary Action Bar
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        icon: Icon(
                          activeProgress != null
                              ? Icons.play_arrow
                              : Icons.menu_book,
                        ),
                        label: Text(
                          activeProgress != null
                              ? 'Continue Ch. ${activeProgress.chapterNumber}'
                              : sortedChapters.isNotEmpty
                              ? 'Start Reading'
                              : 'No Chapters Yet',
                        ),
                        onPressed: sortedChapters.isNotEmpty
                            ? () {
                                final targetChapter = activeProgress != null
                                    ? sortedChapters.firstWhere(
                                        (c) => c.id == activeProgress.chapterId,
                                        orElse: () => sortedChapters.first,
                                      )
                                    : sortedChapters.first;
                                context.push(
                                  AppRoutes.readingPath(
                                    novel.id,
                                    targetChapter.id,
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          isFollowing ? Icons.check : Icons.favorite_border,
                          size: 18,
                        ),
                        label: Text(isFollowing ? 'Following' : 'Follow'),
                        onPressed: () async {
                          final uid = authProvider.currentUid;
                          if (uid != null) {
                            await libraryProvider.toggleFollow(uid, novel.id);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Synopsis Section
                Text(
                  'Synopsis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    novel.description.isNotEmpty
                        ? novel.description
                        : 'No description provided.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Chapters Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chapters (${sortedChapters.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sortedChapters.isNotEmpty)
                      Text(
                        'Published releases',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (sortedChapters.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'No published chapters available yet for this novel.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedChapters.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                    itemBuilder: (context, index) {
                      final chapter = sortedChapters[index];
                      final isCurrent = activeProgress?.chapterId == chapter.id;
                      final pubDate = chapter.publishedAt ?? chapter.createdAt;

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: isCurrent
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          child: Text(
                            '${chapter.chapterNumber}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCurrent
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        title: Text(
                          chapter.title,
                          style: TextStyle(
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isCurrent ? colorScheme.primary : null,
                          ),
                        ),
                        subtitle: pubDate != null
                            ? Text(
                                DateTimeUtil.timeAgo(pubDate),
                                style: const TextStyle(fontSize: 11),
                              )
                            : null,
                        trailing: isCurrent
                            ? Chip(
                                label: const Text('Reading'),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.primary,
                                ),
                              )
                            : const Icon(Icons.chevron_right, size: 18),
                        onTap: () {
                          context.push(
                            AppRoutes.readingPath(novel.id, chapter.id),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
