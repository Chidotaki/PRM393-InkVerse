/// Centralized Firestore collection names.
///
/// Prevents hardcoding collection names across repositories and services.
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String novels = 'novels';
  static const String chapters = 'chapters';
  static const String follows = 'follows';
  static const String bookmarks = 'bookmarks';
  static const String readingProgress = 'reading_progress';
  static const String comments = 'comments';
  static const String reports = 'reports';
  static const String genres = 'genres';
}
