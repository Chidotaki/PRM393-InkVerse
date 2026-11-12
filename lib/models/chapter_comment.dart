import '../core/utils/date_time_util.dart';

/// Represents a reader comment on a chapter.
///
/// Supports soft delete (`isDeleted = true`) to preserve thread integrity.
class ChapterComment {
  final String id;
  final String userId;
  final String userName;
  final String novelId;
  final String chapterId;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const ChapterComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.novelId,
    required this.chapterId,
    required this.content,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory ChapterComment.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return ChapterComment(
      id: (documentId ?? map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? 'Reader').toString(),
      novelId: (map['novelId'] ?? '').toString(),
      chapterId: (map['chapterId'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      createdAt: DateTimeUtil.parse(map['createdAt']),
      updatedAt: DateTimeUtil.parse(map['updatedAt']),
      isDeleted: map['isDeleted'] is bool ? map['isDeleted'] as bool : false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'novelId': novelId,
      'chapterId': chapterId,
      'content': content,
      'createdAt': DateTimeUtil.toFirestore(createdAt),
      'updatedAt': DateTimeUtil.toFirestore(updatedAt),
      'isDeleted': isDeleted,
    };
  }

  ChapterComment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? novelId,
    String? chapterId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ChapterComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      novelId: novelId ?? this.novelId,
      chapterId: chapterId ?? this.chapterId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
