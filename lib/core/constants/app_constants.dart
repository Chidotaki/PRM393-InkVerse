/// Application-wide constants and configuration values.
class AppConstants {
  AppConstants._();

  static const String appName = 'InkVerse';
  static const String appTagline = 'Serial Novel Platform';

  // Seed / Fallback defaults
  static const List<String> defaultGenres = [
    'Fantasy',
    'Romance',
    'Mystery',
    'Adventure',
    'Sci-Fi',
    'Horror',
    'Drama',
    'Comedy',
    'Historical',
    'Slice of Life',
  ];

  // Preference keys
  static const String prefFontSize = 'pref_font_size';
  static const String prefLineSpacing = 'pref_line_spacing';
  static const String prefReadingTheme = 'pref_reading_theme';

  // Reading defaults
  static const double defaultFontSize = 16.0;
  static const double defaultLineSpacing = 1.5;
  static const String defaultReadingTheme = 'light'; // light, dark, sepia
}

/// Novel sorting options for discovery and search.
enum NovelSort { recentlyUpdated, mostPopular, mostFollowed, titleAZ }

extension NovelSortExtension on NovelSort {
  String get label {
    switch (this) {
      case NovelSort.recentlyUpdated:
        return 'Recently Updated';
      case NovelSort.mostPopular:
        return 'Most Popular';
      case NovelSort.mostFollowed:
        return 'Most Followed';
      case NovelSort.titleAZ:
        return 'Title (A-Z)';
    }
  }
}
