import 'package:flutter/material.dart';

import '../core/utils/date_time_util.dart';
import '../models/novel.dart';
import 'genre_chip.dart';
import 'novel_cover.dart';
import 'status_chip.dart';

/// Clean row tile for displaying novel updates, library items, or search results.
class NovelListTile extends StatelessWidget {
  final Novel novel;
  final VoidCallback? onTap;
  final Widget? trailing;

  const NovelListTile({
    super.key,
    required this.novel,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final updatedDate = novel.updatedAt ?? novel.createdAt;
    final timeString = updatedDate != null
        ? DateTimeUtil.timeAgo(updatedDate)
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover thumbnail
              NovelCover(
                title: novel.title,
                authorName: novel.authorName,
                coverUrl: novel.coverUrl,
                genres: novel.genres,
                width: 60,
                height: 88,
                borderRadius: 6,
                showTitleFallback: false,
              ),
              const SizedBox(width: 14),

              // Metadata Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'by ${novel.authorName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusChip(status: novel.status),
                        if (novel.genres.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          GenreChip(label: novel.genres.first, compact: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${novel.chapterCount} chapters',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (timeString.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '•  $timeString',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              if (trailing != null)
                trailing!
              else
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
