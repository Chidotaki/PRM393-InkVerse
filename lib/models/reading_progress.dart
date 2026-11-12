import '../core/utils/date_time_util.dart';

/// Tracks the reader's last reading state for a novel.
///
/// Uses deterministic ID: `${userId}_${novelId}` ensuring exactly one progress
/// document per user per novel (for "Continue Reading").
class ReadingProgress {
  final String id;
  final String userId;
  final String novelId;
  final String novelTitle;
  final String coverUrl;
  final String chapterId;
  final String chapterTitle;
  final int chapterNumber;
  final double progressPercent;
  final DateTime? lastReadAt;

  const ReadingProgress({
    required this.id,
    required this.userId,
    required this.novelId,
    required this.novelTitle,
    this.coverUrl = '',
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterNumber,
    this.progressPercent = 1.0,
    this.lastReadAt,
  });

  static String generateId(String userId, String novelId) =>
      '${userId}_$novelId';

  factory ReadingProgress.create({
    required String userId,
    required String novelId,
    required String novelTitle,
    String coverUrl = '',
    required String chapterId,
    required String chapterTitle,
    required int chapterNumber,
    double progressPercent = 1.0,
    DateTime? lastReadAt,
  }) {
    return ReadingProgress(
      id: generateId(userId, novelId),
      userId: userId,
      novelId: novelId,
      novelTitle: novelTitle,
      coverUrl: coverUrl,
      chapterId: chapterId,
      chapterTitle: chapterTitle,
      chapterNumber: chapterNumber,
      progressPercent: progressPercent,
      lastReadAt: lastReadAt ?? DateTime.now(),
    );
  }

  factory ReadingProgress.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    final userId = (map['userId'] ?? '').toString();
    final novelId = (map['novelId'] ?? '').toString();

    return ReadingProgress(
      id: documentId ?? (map['id'] ?? generateId(userId, novelId)).toString(),
      userId: userId,
      novelId: novelId,
      novelTitle: (map['novelTitle'] ?? '').toString(),
      coverUrl: (map['coverUrl'] ?? '').toString(),
      chapterId: (map['chapterId'] ?? '').toString(),
      chapterTitle: (map['chapterTitle'] ?? '').toString(),
      chapterNumber: (map['chapterNumber'] as num?)?.toInt() ?? 1,
      progressPercent: (map['progressPercent'] as num?)?.toDouble() ?? 1.0,
      lastReadAt: DateTimeUtil.parse(map['lastReadAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'novelId': novelId,
      'novelTitle': novelTitle,
      'coverUrl': coverUrl,
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'chapterNumber': chapterNumber,
      'progressPercent': progressPercent,
      'lastReadAt': DateTimeUtil.toFirestore(lastReadAt),
    };
  }

  ReadingProgress copyWith({
    String? id,
    String? userId,
    String? novelId,
    String? novelTitle,
    String? coverUrl,
    String? chapterId,
    String? chapterTitle,
    int? chapterNumber,
    double? progressPercent,
    DateTime? lastReadAt,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      novelId: novelId ?? this.novelId,
      novelTitle: novelTitle ?? this.novelTitle,
      coverUrl: coverUrl ?? this.coverUrl,
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      progressPercent: progressPercent ?? this.progressPercent,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}
