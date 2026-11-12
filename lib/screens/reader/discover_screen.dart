import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../models/novel.dart';
import '../../providers/novel_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/novel_card.dart';

/// Discover screen allowing readers to search, filter by genre & status,
/// sort, and explore serialized novels in a responsive grid.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final novelProvider = context.read<NovelProvider>();
    _searchController = TextEditingController(text: novelProvider.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _calculateCrossAxisCount(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final visibleNovels = novelProvider.visibleNovels;
    final hasActiveFilters =
        novelProvider.searchQuery.isNotEmpty ||
        novelProvider.selectedGenre != null ||
        novelProvider.selectedStatus != null ||
        novelProvider.selectedSort != NovelSort.recentlyUpdated;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover Novels',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (hasActiveFilters)
            TextButton.icon(
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Reset'),
              onPressed: () {
                _searchController.clear();
                novelProvider.resetFilters();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title or author...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          novelProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => novelProvider.setSearchQuery(value),
            ),
          ),

          // Genre Filter Chips Horizontal Scroll
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                GenreChip(
                  label: 'All Genres',
                  isSelected: novelProvider.selectedGenre == null,
                  onTap: () => novelProvider.setSelectedGenre(null),
                  compact: true,
                ),
                const SizedBox(width: 6),
                ...AppConstants.defaultGenres.map((genre) {
                  final isSelected =
                      novelProvider.selectedGenre?.toLowerCase() ==
                      genre.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GenreChip(
                      label: genre,
                      isSelected: isSelected,
                      onTap: () {
                        novelProvider.setSelectedGenre(
                          isSelected ? null : genre,
                        );
                      },
                      compact: true,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Status & Sort Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Status Filter Menu
                PopupMenuButton<NovelStatus?>(
                  tooltip: 'Filter by Status',
                  initialValue: novelProvider.selectedStatus,
                  onSelected: (status) =>
                      novelProvider.setSelectedStatus(status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          novelProvider.selectedStatus?.label ?? 'All Statuses',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<NovelStatus?>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    const PopupMenuItem<NovelStatus?>(
                      value: NovelStatus.ongoing,
                      child: Text('Ongoing'),
                    ),
                    const PopupMenuItem<NovelStatus?>(
                      value: NovelStatus.completed,
                      child: Text('Completed'),
                    ),
                    const PopupMenuItem<NovelStatus?>(
                      value: NovelStatus.hiatus,
                      child: Text('On Hiatus'),
                    ),
                  ],
                ),
                const Spacer(),

                // Sort Dropdown
                PopupMenuButton<NovelSort>(
                  tooltip: 'Sort Novels',
                  initialValue: novelProvider.selectedSort,
                  onSelected: (sort) => novelProvider.setSelectedSort(sort),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getSortLabel(novelProvider.selectedSort),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<NovelSort>(
                      value: NovelSort.recentlyUpdated,
                      child: Text('Recently Updated'),
                    ),
                    const PopupMenuItem<NovelSort>(
                      value: NovelSort.mostPopular,
                      child: Text('Most Popular'),
                    ),
                    const PopupMenuItem<NovelSort>(
                      value: NovelSort.mostFollowed,
                      child: Text('Most Followed'),
                    ),
                    const PopupMenuItem<NovelSort>(
                      value: NovelSort.titleAZ,
                      child: Text('Title (A to Z)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Count summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${visibleNovels.length} ${visibleNovels.length == 1 ? 'novel' : 'novels'} available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Grid of Novels
          Expanded(
            child: novelProvider.loading
                ? const LoadingState(message: 'Loading stories...')
                : visibleNovels.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No novels found',
                    message: hasActiveFilters
                        ? 'No stories match your current search and filter settings. Try adjusting or resetting them.'
                        : 'No published serialized novels are currently available.',
                    actionLabel: hasActiveFilters ? 'Clear Filters' : null,
                    onAction: hasActiveFilters
                        ? () {
                            _searchController.clear();
                            novelProvider.resetFilters();
                          }
                        : null,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = _calculateCrossAxisCount(
                        constraints.maxWidth,
                      );
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.50,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: visibleNovels.length,
                        itemBuilder: (context, index) {
                          final novel = visibleNovels[index];
                          return NovelCard(
                            novel: novel,
                            width: double.infinity,
                            onTap: () => context.push(
                              AppRoutes.novelDetailPath(novel.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(NovelSort sort) {
    switch (sort) {
      case NovelSort.recentlyUpdated:
        return 'Recent';
      case NovelSort.mostPopular:
        return 'Popular';
      case NovelSort.mostFollowed:
        return 'Followed';
      case NovelSort.titleAZ:
        return 'A-Z';
    }
  }
}
