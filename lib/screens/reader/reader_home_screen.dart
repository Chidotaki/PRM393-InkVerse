import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../models/novel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/novel_provider.dart';
import '../../widgets/continue_reading_card.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/novel_card.dart';
import '../../widgets/novel_list_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/user_avatar.dart';

/// Primary Reader landing screen featuring trending serialized novels,
/// active reading resumption, genre discovery, and recently updated works.
class ReaderHomeScreen extends StatefulWidget {
  const ReaderHomeScreen({super.key});

  @override
  State<ReaderHomeScreen> createState() => _ReaderHomeScreenState();
}

class _ReaderHomeScreenState extends State<ReaderHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final uid = auth.currentUid;
      if (uid != null && uid.isNotEmpty) {
        context.read<LibraryProvider>().loadLibrary(uid);
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final novelProvider = context.watch<NovelProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final user = auth.currentUser;
    final displayName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : null;

    final greeting = displayName != null
        ? '${_getGreeting()}, $displayName'
        : 'Welcome back';

    // Trending novels (sorted by views/popularity)
    final allNovels = novelProvider.allNovels
        .where((n) => n.visibility == NovelVisibility.published)
        .toList();

    final trendingNovels = List<Novel>.from(allNovels)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));

    // Recently updated novels
    final recentNovels = List<Novel>.from(allNovels)
      ..sort((a, b) {
        final timeA = a.updatedAt ?? a.createdAt ?? DateTime(0);
        final timeB = b.updatedAt ?? b.createdAt ?? DateTime(0);
        return timeB.compareTo(timeA);
      });

    // Continue reading entry
    final latestReading = libraryProvider.readingHistory.isNotEmpty
        ? libraryProvider.readingHistory.first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_stories,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppConstants.appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search & Discover',
            onPressed: () => context.go(AppRoutes.discover),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => context.go(AppRoutes.profile),
              borderRadius: BorderRadius.circular(20),
              child: UserAvatar(
                name: user?.fullName,
                email: user?.email,
                avatarUrl: user?.avatarUrl,
                radius: 16,
              ),
            ),
          ),
        ],
      ),
      body: novelProvider.loading && allNovels.isEmpty
          ? const LoadingState(message: 'Loading InkVerse library...')
          : RefreshIndicator(
              onRefresh: () async {
                await novelProvider.fetchNovels();
                final uid = auth.currentUid;
                if (uid != null) {
                  await libraryProvider.loadLibrary(uid);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Discover captivating stories, serialized chapter by chapter.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Continue Reading Section (if user has active history)
                    if (latestReading != null) ...[
                      SectionHeader(
                        title: 'Continue Reading',
                        subtitle: 'Resume where you left off',
                        actionLabel: 'History',
                        onAction: () => context.go(AppRoutes.history),
                      ),
                      ContinueReadingCard(
                        progress: latestReading,
                        onContinue: () {
                          context.push(
                            AppRoutes.readingPath(
                              latestReading.novelId,
                              latestReading.chapterId,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Trending Now Section
                    if (trendingNovels.isNotEmpty) ...[
                      SectionHeader(
                        title: 'Trending Now',
                        subtitle: 'Most read serialized novels this week',
                        actionLabel: 'See All',
                        onAction: () {
                          novelProvider.setSelectedSort(NovelSort.mostPopular);
                          context.go(AppRoutes.discover);
                        },
                      ),
                      SizedBox(
                        height: 315,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: trendingNovels.take(8).length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final novel = trendingNovels[index];
                            return NovelCard(
                              novel: novel,
                              width: 140,
                              onTap: () => context.push(
                                AppRoutes.novelDetailPath(novel.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Popular Genres Chips
                    SectionHeader(
                      title: 'Popular Genres',
                      subtitle: 'Browse stories by literary flavor',
                    ),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.defaultGenres.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final genre = AppConstants.defaultGenres[index];
                          return GenreChip(
                            label: genre,
                            onTap: () {
                              novelProvider.setSelectedGenre(genre);
                              context.go(AppRoutes.discover);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recently Updated Section
                    if (recentNovels.isNotEmpty) ...[
                      SectionHeader(
                        title: 'Recently Updated',
                        subtitle: 'Latest chapter releases',
                        actionLabel: 'Explore',
                        onAction: () {
                          novelProvider.setSelectedSort(
                            NovelSort.recentlyUpdated,
                          );
                          context.go(AppRoutes.discover);
                        },
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: recentNovels.take(5).length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          indent: 86,
                          endIndent: 16,
                          color: colorScheme.outline.withValues(alpha: 0.1),
                        ),
                        itemBuilder: (context, index) {
                          final novel = recentNovels[index];
                          return NovelListTile(
                            novel: novel,
                            onTap: () => context.push(
                              AppRoutes.novelDetailPath(novel.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
