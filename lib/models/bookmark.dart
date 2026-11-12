import '../core/utils/date_time_util.dart';

/// Represents a bookmarked chapter by a reader.
///
/// Uses deterministic ID: `${userId}_${novelId}_${chapterId}` to avoid duplicates.
class Bookmark {
  final String id;
  final String userId;
  final String novelId;
  final String chapterId;
  final int chapterNumber;
  final String novelTitle;
  final String chapterTitle;
  final DateTime? createdAt;

  const Bookmark({
    required this.id,
    required this.userId,
    required this.novelId,
    required this.chapterId,
    required this.chapterNumber,
    required this.novelTitle,
    required this.chapterTitle,
    this.createdAt,
  });

  static String generateId(String userId, String novelId, String chapterId) =>
      '${userId}_${novelId}_$chapterId';

  factory Bookmark.create({
    required String userId,
    required String novelId,
    required String chapterId,
    required int chapterNumber,
    required String novelTitle,
    required String chapterTitle,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: generateId(userId, novelId, chapterId),
      userId: userId,
      novelId: novelId,
      chapterId: chapterId,
      chapterNumber: chapterNumber,
      novelTitle: novelTitle,
      chapterTitle: chapterTitle,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory Bookmark.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final userId = (map['userId'] ?? '').toString();
    final novelId = (map['novelId'] ?? '').toString();
    final chapterId = (map['chapterId'] ?? '').toString();

    return Bookmark(
      id:
          documentId ??
          (map['id'] ?? generateId(userId, novelId, chapterId)).toString(),
      userId: userId,
      novelId: novelId,
      chapterId: chapterId,
      chapterNumber: (map['chapterNumber'] as num?)?.toInt() ?? 1,
      novelTitle: (map['novelTitle'] ?? '').toString(),
      chapterTitle: (map['chapterTitle'] ?? '').toString(),
      createdAt: DateTimeUtil.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'novelId': novelId,
      'chapterId': chapterId,
      'chapterNumber': chapterNumber,
      'novelTitle': novelTitle,
      'chapterTitle': chapterTitle,
      'createdAt': DateTimeUtil.toFirestore(createdAt),
    };
  }

  Bookmark copyWith({
    String? id,
    String? userId,
    String? novelId,
    String? chapterId,
    int? chapterNumber,
    String? novelTitle,
    String? chapterTitle,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      novelId: novelId ?? this.novelId,
      chapterId: chapterId ?? this.chapterId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      novelTitle: novelTitle ?? this.novelTitle,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
