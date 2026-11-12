import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/utils/date_time_util.dart';
import '../../models/chapter.dart';
import '../../models/novel.dart';
import '../../providers/author_provider.dart';
import '../../providers/novel_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';

/// Screen for managing all chapters of a specific serialized novel.
class ChapterManagementScreen extends StatefulWidget {
  final String novelId;

  const ChapterManagementScreen({super.key, required this.novelId});

  @override
  State<ChapterManagementScreen> createState() =>
      _ChapterManagementScreenState();
}

class _ChapterManagementScreenState extends State<ChapterManagementScreen> {
  Novel? _novel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authorProvider = context.read<AuthorProvider>();
    final novelProvider = context.read<NovelProvider>();

    // Load chapters
    authorProvider.loadChapters(widget.novelId);

    // Load novel metadata for header
    Novel? found = authorProvider.myNovels
        .where((n) => n.id == widget.novelId)
        .firstOrNull;

    if (found == null) {
      try {
        found = await novelProvider.getNovelById(widget.novelId);
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _novel = found;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorProvider = context.watch<AuthorProvider>();

    final chapters = authorProvider.getChaptersForNovel(widget.novelId);
    final sortedChapters = List<Chapter>.from(chapters)
      ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

    final novelTitle = _novel?.title ?? 'Novel Chapters';

    return Scaffold(
      appBar: AppBar(
        title: Text(novelTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: authorProvider.loading ? null : _loadData,
          ),
          IconButton(
            tooltip: 'New Chapter',
            icon: const Icon(Icons.add),
            onPressed: () =>
                context.push(AppRoutes.authorChapterNewPath(widget.novelId)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accentTeal,
        foregroundColor: Colors.black87,
        onPressed: () =>
            context.push(AppRoutes.authorChapterNewPath(widget.novelId)),
        icon: const Icon(Icons.add),
        label: const Text(
          'New Chapter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: authorProvider.loading && sortedChapters.isEmpty
          ? const LoadingState(message: 'Loading chapters...')
          : RefreshIndicator(
              onRefresh: _loadData,
              child: sortedChapters.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: EmptyState(
                          icon: Icons.article_outlined,
                          title: 'No Chapters Yet',
                          message: 'Write Chapter 1 to start releasing your story to readers.',
                          actionLabel: 'Create First Chapter',
                          onAction: () => context.push(
                            AppRoutes.authorChapterNewPath(widget.novelId),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: sortedChapters.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final chapter = sortedChapters[index];
                        return _buildChapterCard(context, chapter);
                      },
                    ),
            ),
    );
  }

  Widget _buildChapterCard(BuildContext context, Chapter chapter) {
    final isDraft = chapter.status == ChapterStatus.draft;

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
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Text(
                    'Ch. ${chapter.chapterNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.accentTeal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chapter.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textHighContrast,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _statusBadge(chapter.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.text_snippet_outlined,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${chapter.wordCount} words',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 14),
                if (chapter.publishedAt != null)
                  Text(
                    'Published ${DateTimeUtil.formatDate(chapter.publishedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  )
                else if (chapter.createdAt != null)
                  Text(
                    'Created ${DateTimeUtil.formatDate(chapter.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppTheme.borderDark, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () => context.push(
                    '/author/novel/${widget.novelId}/chapter/${chapter.id}/edit',
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                if (isDraft) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => _handlePublish(chapter),
                    icon: const Icon(Icons.publish, size: 16),
                    label: const Text('Publish'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Delete Draft',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () => _handleDeleteDraft(chapter),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber,
                      side: const BorderSide(color: Colors.amber),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => _handleUnpublish(chapter),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Unpublish'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(ChapterStatus status) {
    final isPublished = status == ChapterStatus.published;
    final color = isPublished ? Colors.green : Colors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _handlePublish(Chapter chapter) async {
    try {
      await context.read<AuthorProvider>().publishChapter(
        widget.novelId,
        chapter.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal[800],
          content: Text('Chapter ${chapter.chapterNumber} published!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to publish chapter: $e'),
        ),
      );
    }
  }

  Future<void> _handleUnpublish(Chapter chapter) async {
    try {
      await context.read<AuthorProvider>().unpublishChapter(
        widget.novelId,
        chapter.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[900],
          content: Text('Chapter ${chapter.chapterNumber} reverted to draft.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to unpublish chapter: $e'),
        ),
      );
    }
  }

  Future<void> _handleDeleteDraft(Chapter chapter) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Draft Chapter?'),
        content: Text(
          'Delete Chapter ${chapter.chapterNumber}: "${chapter.title}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<AuthorProvider>().deleteDraftChapter(
        widget.novelId,
        chapter.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.teal,
          content: Text('Draft chapter deleted.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to delete chapter: $e'),
        ),
      );
    }
  }
}
