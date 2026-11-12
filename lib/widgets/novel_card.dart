import 'package:flutter/material.dart';

import '../models/novel.dart';
import 'genre_chip.dart';
import 'novel_cover.dart';
import 'status_chip.dart';

/// Versatile card displaying novel metadata for horizontal carousels or responsive grids.
class NovelCard extends StatelessWidget {
  final Novel novel;
  final VoidCallback? onTap;
  final double width;
  final bool compact;

  const NovelCard({
    super.key,
    required this.novel,
    this.onTap,
    this.width = 140,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Novel Cover with Status badge overlay
              AspectRatio(
                aspectRatio: 1 / 1.35,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NovelCover(
                      title: novel.title,
                      authorName: novel.authorName,
                      coverUrl: novel.coverUrl,
                      genres: novel.genres,
                      width: width.isFinite ? width : null,
                      borderRadius: 10,
                      showTitleFallback: false,
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: StatusChip(status: novel.status),
                    ),
                    if (novel.chapterCount > 0)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${novel.chapterCount} ch',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                novel.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),

              // Author Name
              Text(
                novel.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),

              // Genre & Views row
              Row(
                children: [
                  if (novel.genres.isNotEmpty)
                    Expanded(
                      child: GenreChip(
                        label: novel.genres.first,
                        compact: true,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatNumber(novel.viewCount),
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
