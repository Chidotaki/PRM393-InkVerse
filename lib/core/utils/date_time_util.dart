import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Utilities for parsing timestamps safely across Firestore, local storage,
/// and mock backends.
class DateTimeUtil {
  DateTimeUtil._();

  static final DateFormat _dateFormat = DateFormat('MMM d, y');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, y • HH:mm');

  /// Safely converts Firestore [Timestamp], [DateTime], ISO-8601 [String],
  /// or epoch [int] to a [DateTime].
  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Converts a [DateTime] into a format suitable for Firestore storage.
  /// If [dateTime] is null, returns null.
  static dynamic toFirestore(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }

  /// Format date: e.g. "Nov 12, 2026"
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateFormat.format(dateTime);
  }

  /// Format date time: e.g. "Nov 12, 2026 • 15:30"
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateTimeFormat.format(dateTime);
  }

  /// Simple time-ago format: e.g. "2h ago", "Just now"
  static String timeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return formatDate(dateTime);
  }
}
