import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/utils/date_time_util.dart';
import '../../models/novel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/author_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/novel_cover.dart';
import '../../widgets/status_chip.dart';

enum NovelFilter { all, draft, published, archived }

/// Screen presenting the author's complete portfolio of serialized novels,
/// with status filtering, publishing controls, and archive capabilities.
class MyNovelsScreen extends StatefulWidget {
  const MyNovelsScreen({super.key});

  @override
  State<MyNovelsScreen> createState() => _MyNovelsScreenState();
}

class _MyNovelsScreenState extends State<MyNovelsScreen> {
  NovelFilter _filter = NovelFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    final uid = auth.currentUid;
    if (uid != null && uid.isNotEmpty) {
      context.read<AuthorProvider>().loadMyNovels(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorProvider = context.watch<AuthorProvider>();
    final auth = context.watch<AuthProvider>();

    final allNovels = authorProvider.myNovels;

    final filteredNovels = allNovels.where((n) {
      switch (_filter) {
        case NovelFilter.all:
          return true;
        case NovelFilter.draft:
          return n.isDraft;
        case NovelFilter.published:
          return n.isPublished;
        case NovelFilter.archived:
          return !n.isPublished && !n.isDraft;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Novels'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: authorProvider.loading ? null : _loadData,
          ),
          IconButton(
            tooltip: 'Create Novel',
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.authorNovelNew),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accentTeal,
        foregroundColor: Colors.black87,
        onPressed: () => context.push(AppRoutes.authorNovelNew),
        icon: const Icon(Icons.add),
        label: const Text(
          'Create Novel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterBar(),

          // Main Content
          Expanded(
            child: authorProvider.loading && allNovels.isEmpty
                ? const LoadingState(message: 'Loading your novels...')
                : RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: filteredNovels.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: filteredNovels.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final novel = filteredNovels[index];
                              return _buildNovelCard(
                                novel,
                                auth.currentUid ?? '',
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.5)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', NovelFilter.all),
            const SizedBox(width: 8),
            _filterChip('Draft', NovelFilter.draft),
            const SizedBox(width: 8),
            _filterChip('Published', NovelFilter.published),
            const SizedBox(width: 8),
            _filterChip('Archived', NovelFilter.archived),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, NovelFilter filter) {
    final selected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) setState(() => _filter = filter);
      },
      selectedColor: AppTheme.accentTeal.withValues(alpha: 0.2),
      side: BorderSide(
        color: selected ? AppTheme.accentTeal : AppTheme.borderDark,
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? AppTheme.accentTeal : AppTheme.textMuted,
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String message;

    switch (_filter) {
      case NovelFilter.draft:
        title = 'No Drafts';
        message = 'You have no novels currently in draft status.';
        break;
      case NovelFilter.published:
        title = 'No Published Novels';
        message = 'You have not published any novels yet.';
        break;
      case NovelFilter.archived:
        title = 'No Archived Novels';
        message = 'No novels in your archive.';
        break;
      case NovelFilter.all:
        title = 'No Novels Created';
        message = 'Create your first novel to begin serial publishing.';
        break;
    }

    return Center(
      child: SingleChildScrollView(
        child: EmptyState(
          icon: Icons.book_outlined,
          title: title,
          message: message,
          actionLabel: _filter == NovelFilter.all ? 'Create Novel' : null,
          onAction: _filter == NovelFilter.all
              ? () => context.push(AppRoutes.authorNovelNew)
              : null,
        ),
      ),
    );
  }

  Widget _buildNovelCard(Novel novel, String currentUid) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NovelCover(
                  title: novel.title,
                  authorName: novel.authorName,
                  coverUrl: novel.coverUrl,
                  genres: novel.genres,
                  width: 72,
                  height: 104,
                  borderRadius: 8,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              novel.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textHighContrast,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildVisibilityBadge(novel.visibility),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          StatusChip(status: novel.status),
                          for (final g in novel.genres.take(2))
                            GenreChip(label: g, isSelected: false),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Metrics
                      Row(
                        children: [
                          const Icon(
                            Icons.article_outlined,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${novel.chapterCount} ch',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${novel.viewCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.bookmark_outline,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${novel.followerCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.borderDark, height: 1),
            const SizedBox(height: 10),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (novel.updatedAt != null)
                  Text(
                    'Updated ${DateTimeUtil.timeAgo(novel.updatedAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () =>
                      context.push(AppRoutes.authorChaptersPath(novel.id)),
                  icon: const Icon(Icons.list, size: 16),
                  label: const Text('Chapters'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () =>
                      context.push(AppRoutes.authorNovelEditPath(novel.id)),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                if (novel.isDraft)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => _handlePublish(novel, currentUid),
                    icon: const Icon(Icons.publish, size: 16),
                    label: const Text('Publish'),
                  ),
                if (novel.isPublished)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber,
                      side: const BorderSide(color: Colors.amber),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => _handleArchive(novel, currentUid),
                    icon: const Icon(Icons.archive_outlined, size: 16),
                    label: const Text('Archive'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityBadge(NovelVisibility visibility) {
    Color color;
    String label;
    switch (visibility) {
      case NovelVisibility.published:
        color = Colors.green;
        label = 'Published';
        break;
      case NovelVisibility.draft:
        color = Colors.amber;
        label = 'Draft';
        break;
      case NovelVisibility.hidden:
        color = Colors.red;
        label = 'Archived/Hidden';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _handlePublish(Novel novel, String currentUid) async {
    final authorProvider = context.read<AuthorProvider>();

    try {
      await authorProvider.publishNovel(novel.id, currentUid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal[800],
          content: Text('Successfully published "${novel.title}"!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('chapter')
          ? 'Publish at least one chapter before publishing this novel.'
          : 'Unable to publish novel: $e';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(msg),
        ),
      );
    }
  }

  Future<void> _handleArchive(Novel novel, String currentUid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Novel?'),
        content: Text(
          'Archive "${novel.title}"?\nIt will no longer appear in the public Reader catalog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<AuthorProvider>().archiveNovel(novel.id, currentUid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal[800],
          content: Text('Archived "${novel.title}".'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to archive novel: $e'),
        ),
      );
    }
  }
}
