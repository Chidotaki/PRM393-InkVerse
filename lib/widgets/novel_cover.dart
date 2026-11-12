import 'package:flutter/material.dart';

/// Renders a novel cover image with a reliable, attractive deterministic fallback.
///
/// If [coverUrl] is empty or fails to load, generates a book-jacket layout
/// with gradient tones derived from the novel's title and genre, ensuring
/// demo and offline presentations never show broken images.
class NovelCover extends StatelessWidget {
  final String title;
  final String authorName;
  final String coverUrl;
  final List<String> genres;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool showTitleFallback;

  const NovelCover({
    super.key,
    required this.title,
    this.authorName = '',
    this.coverUrl = '',
    this.genres = const [],
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.showTitleFallback = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (width != null && width!.isFinite)
            ? width!
            : (constraints.hasBoundedWidth ? constraints.maxWidth : 100.0);
        final h = (height != null && height!.isFinite)
            ? height!
            : (constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : (w * 1.5));

        final cleanUrl = coverUrl.trim();
        final bool hasValidNetworkUrl =
            cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: w,
            height: h,
            child: hasValidNetworkUrl
                ? Image.network(
                    cleanUrl,
                    width: w,
                    height: h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildGeneratedCover(w, h),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildGeneratedCover(w, h),
                          Container(
                            color: Colors.black26,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : _buildGeneratedCover(w, h),
          ),
        );
      },
    );
  }

  Widget _buildGeneratedCover(double w, double h) {
    final primaryGenre = genres.isNotEmpty ? genres.first.toLowerCase() : '';
    final palette = _getPaletteForGenreAndTitle(primaryGenre, title);

    final initials = _getInitials(title);

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.startColor, palette.endColor],
        ),
      ),
      child: Stack(
        children: [
          // Subtle book spine accent on left edge
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: w > 80 ? 6 : 3,
            child: Container(color: Colors.black.withValues(alpha: 0.25)),
          ),

          // Geometric decorative pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _CoverPatternPainter(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w > 80 ? 10 : 6,
              vertical: h > 120 ? 12 : 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Genre badge or icon
                if (genres.isNotEmpty && h >= 100)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      genres.first.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: w > 100 ? 9 : 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // Center Monogram / Initials
                Center(
                  child: Container(
                    width: w * 0.45,
                    height: w * 0.45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (w * 0.2).clamp(10.0, 28.0),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),

                // Title & Author text footer
                if (showTitleFallback && h >= 100)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: w > 100 ? 11 : 9,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      if (authorName.isNotEmpty && h >= 140) ...[
                        const SizedBox(height: 3),
                        Text(
                          authorName,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: w > 100 ? 9 : 8,
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'IV';
    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length.clamp(1, 2))
          .toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  _CoverPalette _getPaletteForGenreAndTitle(String genre, String title) {
    if (genre.contains('fant')) {
      return const _CoverPalette(
        Color(0xFF042F2E),
        Color(0xFF0F766E),
      ); // Emerald & Teal
    } else if (genre.contains('sci') || genre.contains('space')) {
      return const _CoverPalette(
        Color(0xFF0F172A),
        Color(0xFF0284C7),
      ); // Dark Navy & Cyan
    } else if (genre.contains('romance')) {
      return const _CoverPalette(
        Color(0xFF4C0519),
        Color(0xFFBE185D),
      ); // Plum & Rose
    } else if (genre.contains('myst') ||
        genre.contains('thrill') ||
        genre.contains('horror')) {
      return const _CoverPalette(
        Color(0xFF18181B),
        Color(0xFF3F3F46),
      ); // Charcoal & Slate
    } else if (genre.contains('adv') || genre.contains('action')) {
      return const _CoverPalette(
        Color(0xFF451A03),
        Color(0xFFB45309),
      ); // Bronze & Amber
    } else if (genre.contains('hist')) {
      return const _CoverPalette(
        Color(0xFF2E1065),
        Color(0xFF6D28D9),
      ); // Deep Purple & Violet
    } else if (genre.contains('slice') ||
        genre.contains('life') ||
        genre.contains('drama')) {
      return const _CoverPalette(
        Color(0xFF14532D),
        Color(0xFF15803D),
      ); // Forest & Sage
    }

    // Hash-based deterministic fallback
    final hash = title.hashCode.abs();
    final fallbacks = [
      const _CoverPalette(Color(0xFF1E1B4B), Color(0xFF4338CA)),
      const _CoverPalette(Color(0xFF064E3B), Color(0xFF059669)),
      const _CoverPalette(Color(0xFF701A75), Color(0xFFC026D3)),
      const _CoverPalette(Color(0xFF164E63), Color(0xFF0891B2)),
    ];
    return fallbacks[hash % fallbacks.length];
  }
}

class _CoverPalette {
  final Color startColor;
  final Color endColor;
  const _CoverPalette(this.startColor, this.endColor);
}

class _CoverPatternPainter extends CustomPainter {
  final Color color;
  _CoverPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 18.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
