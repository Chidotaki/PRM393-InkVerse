import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/utils/date_time_util.dart';
import '../../models/novel.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/novel_cover.dart';
import '../../widgets/status_chip.dart';

enum NovelModerationFilter { all, published, hidden, draft }

/// Admin moderation screen to audit the novel catalog, hide violating content,
/// or restore hidden titles.
class NovelModerationScreen extends StatefulWidget {
  const NovelModerationScreen({super.key});

  @override
  State<NovelModerationScreen> createState() => _NovelModerationScreenState();
}

class _NovelModerationScreenState extends State<NovelModerationScreen> {
  final _searchController = TextEditingController();
  NovelModerationFilter _filter = NovelModerationFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<AdminProvider>().loadAllNovels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    final allNovels = admin.novels;

    final filteredNovels = allNovels.where((n) {
      if (_searchQuery.isNotEmpty) {
        final titleMatch = n.title.toLowerCase().contains(_searchQuery);
        final authorMatch = n.authorName.toLowerCase().contains(_searchQuery);
        if (!titleMatch && !authorMatch) return false;
      }

      switch (_filter) {
        case NovelModerationFilter.all:
          return true;
        case NovelModerationFilter.published:
          return n.isPublished;
        case NovelModerationFilter.hidden:
          return n.isHidden;
        case NovelModerationFilter.draft:
          return n.isDraft;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novel Moderation'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: admin.loading ? null : _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: admin.loading && allNovels.isEmpty
                ? const LoadingState(message: 'Loading novels...')
                : RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: filteredNovels.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: EmptyState(
                                icon: Icons.menu_book_outlined,
                                title: 'No Novels Found',
                                message: _searchQuery.isNotEmpty
                                    ? 'No novels match "$_searchQuery".'
                                    : 'No novels in this category.',
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredNovels.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final novel = filteredNovels[index];
                              return _buildNovelCard(novel);
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search title or author...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All Novels', NovelModerationFilter.all),
                const SizedBox(width: 8),
                _filterChip('Published', NovelModerationFilter.published),
                const SizedBox(width: 8),
                _filterChip('Hidden', NovelModerationFilter.hidden),
                const SizedBox(width: 8),
                _filterChip('Draft', NovelModerationFilter.draft),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, NovelModerationFilter filter) {
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
        fontSize: 12,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? AppTheme.accentTeal : AppTheme.textMuted,
      ),
    );
  }

  Widget _buildNovelCard(Novel novel) {
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
                  width: 68,
                  height: 98,
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
                      const SizedBox(height: 4),
                      Text(
                        'by ${novel.authorName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.accentTeal,
                          fontWeight: FontWeight.w500,
                        ),
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
            const SizedBox(height: 8),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (novel.updatedAt != null)
                  Text(
                    'Updated ${DateTimeUtil.timeAgo(novel.updatedAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (novel.isPublished)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () => _handleHide(novel),
                    icon: const Icon(Icons.visibility_off_outlined, size: 16),
                    label: const Text('Hide Novel'),
                  )
                else if (novel.isHidden)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () => _handleRestore(novel),
                    icon: const Icon(Icons.restore_outlined, size: 16),
                    label: const Text('Restore Novel'),
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
      case NovelVisibility.hidden:
        color = Colors.redAccent;
        label = 'Hidden';
        break;
      case NovelVisibility.draft:
        color = Colors.amber;
        label = 'Draft';
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

  Future<void> _handleHide(Novel novel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hide Novel?'),
        content: Text(
          'Hide "${novel.title}" from public view?\nIt will no longer appear in search, discovery, or reader listings.',
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
            child: const Text('Hide Novel'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<AdminProvider>().hideNovel(novel.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal[800],
          content: Text('Novel "${novel.title}" is now hidden.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to hide novel: $e'),
        ),
      );
    }
  }

  Future<void> _handleRestore(Novel novel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Novel?'),
        content: Text(
          'Restore "${novel.title}" to public catalog?\nIt will become visible again to all readers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<AdminProvider>().restoreNovel(novel.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal[800],
          content: Text(
            'Novel "${novel.title}" restored to published catalog.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to restore novel: $e'),
        ),
      );
    }
  }
}
