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
import '../../widgets/loading_state.dart';
import '../../widgets/novel_cover.dart';
import '../../widgets/status_chip.dart';

/// Author Studio Dashboard screen providing metrics, quick actions,
/// and a view of recent serial novels.
class AuthorDashboardScreen extends StatefulWidget {
  const AuthorDashboardScreen({super.key});

  @override
  State<AuthorDashboardScreen> createState() => _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends State<AuthorDashboardScreen> {
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
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final authorProvider = context.watch<AuthorProvider>();
    final user = auth.currentUser;

    final novels = authorProvider.myNovels;
    final publishedCount = novels.where((n) => n.isPublished).length;
    final draftCount = novels.where((n) => n.isDraft).length;
    final archivedCount = novels
        .where((n) => !n.isPublished && !n.isDraft)
        .length;
    final totalChapters = novels.fold<int>(0, (sum, n) => sum + n.chapterCount);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Author Studio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: authorProvider.loading ? null : _loadData,
          ),
          IconButton(
            tooltip: 'Reader Home',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: authorProvider.loading && novels.isEmpty
          ? const LoadingState(message: 'Loading your novels...')
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author Welcome Header Card
                        _buildHeaderCard(context, user?.fullName ?? 'Author'),
                        const SizedBox(height: 24),

                        // Quick Navigation Actions
                        _buildQuickActions(context),
                        const SizedBox(height: 24),

                        // Metrics Overview Grid
                        Text(
                          'Studio Overview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMetricsGrid(
                          context,
                          totalNovels: novels.length,
                          publishedNovels: publishedCount,
                          draftNovels: draftCount,
                          archivedNovels: archivedCount,
                          totalChapters: totalChapters,
                        ),
                        const SizedBox(height: 28),

                        // Recent Novels Header with View All
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Novels',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (novels.isNotEmpty)
                              TextButton.icon(
                                onPressed: () =>
                                    context.push(AppRoutes.authorNovels),
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('View All'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (authorProvider.error != null && novels.isEmpty)
                          _buildErrorCard(context, authorProvider.error!)
                        else if (novels.isEmpty)
                          EmptyState(
                            icon: Icons.auto_stories_outlined,
                            title: 'No Novels Yet',
                            message: 'Create your first serialized novel and start building your audience on InkVerse!',
                            actionLabel: 'Create Novel',
                            onAction: () =>
                                context.push(AppRoutes.authorNovelNew),
                          )
                        else
                          _buildRecentNovelsList(
                            context,
                            novels.take(4).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, String authorName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentTeal.withValues(alpha: 0.15),
            AppTheme.accentPurple.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.accentTeal.withValues(alpha: 0.2),
            child: const Icon(
              Icons.draw_outlined,
              size: 30,
              color: AppTheme.accentTeal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Welcome, $authorName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textHighContrast,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.accentTeal.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'Author Mode Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your serial releases, track readership, and edit chapters.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentTeal,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => context.push(AppRoutes.authorNovelNew),
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'New Novel',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => context.push(AppRoutes.authorNovels),
          icon: const Icon(Icons.library_books_outlined, size: 20),
          label: const Text('My Novels'),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.explore_outlined, size: 20),
          label: const Text('Reader Home'),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context, {
    required int totalNovels,
    required int publishedNovels,
    required int draftNovels,
    required int archivedNovels,
    required int totalChapters,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final count = isWide ? 4 : 2;

        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 1.6 : 1.4,
          children: [
            _metricCard(
              'Total Novels',
              '$totalNovels',
              Icons.book_outlined,
              AppTheme.accentTeal,
            ),
            _metricCard(
              'Published',
              '$publishedNovels',
              Icons.check_circle_outline,
              Colors.green,
            ),
            _metricCard(
              'Drafts',
              '$draftNovels',
              Icons.edit_note_outlined,
              Colors.amber,
            ),
            _metricCard(
              'Chapters',
              '$totalChapters',
              Icons.article_outlined,
              AppTheme.accentPurple,
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNovelsList(BuildContext context, List<Novel> novels) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: novels.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final novel = novels[index];
        return _buildNovelCard(context, novel);
      },
    );
  }

  Widget _buildNovelCard(BuildContext context, Novel novel) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NovelCover(
              title: novel.title,
              authorName: novel.authorName,
              coverUrl: novel.coverUrl,
              genres: novel.genres,
              width: 64,
              height: 92,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _visibilityBadge(novel.visibility),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      StatusChip(status: novel.status),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${novel.chapterCount} ch',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      if (novel.updatedAt != null)
                        Text(
                          'Updated ${DateTimeUtil.timeAgo(novel.updatedAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => context.push(
                          AppRoutes.authorChaptersPath(novel.id),
                        ),
                        icon: const Icon(Icons.list, size: 16),
                        label: const Text('Chapters'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceElevated,
                          foregroundColor: AppTheme.accentTeal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => context.push(
                          AppRoutes.authorNovelEditPath(novel.id),
                        ),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibilityBadge(NovelVisibility visibility) {
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
        label = 'Hidden';
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

  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade700.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: _loadData,
          ),
        ],
      ),
    );
  }
}
