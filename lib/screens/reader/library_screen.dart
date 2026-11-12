import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/utils/date_time_util.dart';
import '../../models/novel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/novel_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/novel_card.dart';
import '../../widgets/novel_cover.dart';

/// Reader Library screen organizing followed serialized novels,
/// saved chapter bookmarks, and reading progress history into dedicated tabs.
class LibraryScreen extends StatefulWidget {
  final int initialTabIndex;

  const LibraryScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshLibrary();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshLibrary() {
    final auth = context.read<AuthProvider>();
    final uid = auth.currentUid;
    if (uid != null && uid.isNotEmpty) {
      context.read<LibraryProvider>().loadLibrary(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final novelProvider = context.watch<NovelProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Followed novels list
    final followedNovels = novelProvider.allNovels
        .where((n) => library.isFollowing(n.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Following'),
                  if (library.followedNovelIds.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(library.followedNovelIds.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bookmarks'),
                  if (library.bookmarks.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(library.bookmarks.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('History'),
                  if (library.readingHistory.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(library.readingHistory.length),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body:
          library.loading && followedNovels.isEmpty && library.bookmarks.isEmpty
          ? const LoadingState(message: 'Loading your library...')
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. Following Tab
                _buildFollowingTab(context, followedNovels),

                // 2. Bookmarks Tab
                _buildBookmarksTab(context, library, auth.currentUid),

                // 3. History Tab
                _buildHistoryTab(context, library),
              ],
            ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildFollowingTab(BuildContext context, List<Novel> followedNovels) {
    if (followedNovels.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_border,
        title: 'No followed novels yet',
        message: 'Start exploring stories to build your personalized library and get updates.',
        actionLabel: 'Explore Stories',
        onAction: () => context.go(AppRoutes.discover),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.52,
            crossAxisSpacing: 14,
            mainAxisSpacing: 16,
          ),
          itemCount: followedNovels.length,
          itemBuilder: (context, index) {
            final novel = followedNovels[index];
            return NovelCard(
              novel: novel,
              width: double.infinity,
              onTap: () => context.push(AppRoutes.novelDetailPath(novel.id)),
            );
          },
        );
      },
    );
  }

  Widget _buildBookmarksTab(
    BuildContext context,
    LibraryProvider library,
    String? currentUid,
  ) {
    final bookmarks = library.bookmarks;
    final colorScheme = Theme.of(context).colorScheme;

    if (bookmarks.isEmpty) {
      return EmptyState(
        icon: Icons.collections_bookmark_outlined,
        title: 'No bookmarks yet',
        message: 'Bookmark a chapter while reading to easily find and return to it later.',
        actionLabel: 'Browse Serials',
        onAction: () => context.go(AppRoutes.discover),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final bm = bookmarks[index];
        final savedDate = bm.createdAt != null
            ? DateTimeUtil.timeAgo(bm.createdAt!)
            : '';
        final novel = context
            .read<NovelProvider>()
            .allNovels
            .where((n) => n.id == bm.novelId)
            .firstOrNull;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            leading: NovelCover(
              title: bm.novelTitle,
              coverUrl: novel?.coverUrl ?? '',
              width: 44,
              height: 64,
              borderRadius: 6,
              showTitleFallback: false,
            ),
            title: Text(
              bm.novelTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                Text(
                  'Chapter ${bm.chapterNumber}: ${bm.chapterTitle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (savedDate.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Bookmarked $savedDate',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_remove_outlined),
              tooltip: 'Remove Bookmark',
              onPressed: () {
                if (currentUid != null) {
                  library.removeBookmark(currentUid, bm.novelId, bm.chapterId);
                }
              },
            ),
            onTap: () {
              context.push(AppRoutes.readingPath(bm.novelId, bm.chapterId));
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context, LibraryProvider library) {
    final history = library.readingHistory;
    final colorScheme = Theme.of(context).colorScheme;

    if (history.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: 'No reading history yet',
        message: 'Open any novel chapter to begin tracking your reading journey automatically.',
        actionLabel: 'Discover Novels',
        onAction: () => context.go(AppRoutes.discover),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = history[index];
        final readDate = item.lastReadAt != null
            ? DateTimeUtil.timeAgo(item.lastReadAt!)
            : '';
        final percent = (item.progressPercent * 100).toInt().clamp(0, 100);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            leading: NovelCover(
              title: item.novelTitle,
              coverUrl: item.coverUrl,
              width: 44,
              height: 64,
              borderRadius: 6,
              showTitleFallback: false,
            ),
            title: Text(
              item.novelTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                Text(
                  'Chapter ${item.chapterNumber}: ${item.chapterTitle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: item.progressPercent.clamp(0.05, 1.0),
                          minHeight: 4,
                          color: colorScheme.primary,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (readDate.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '•  $readDate',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.play_arrow, size: 20),
            onTap: () {
              context.push(AppRoutes.readingPath(item.novelId, item.chapterId));
            },
          ),
        );
      },
    );
  }
}
