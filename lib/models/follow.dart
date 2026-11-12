import '../core/utils/date_time_util.dart';

/// Represents a user following a novel.
///
/// Uses deterministic ID: `${userId}_${novelId}` to prevent duplicate follows.
class Follow {
  final String id;
  final String userId;
  final String novelId;
  final DateTime? createdAt;

  const Follow({
    required this.id,
    required this.userId,
    required this.novelId,
    this.createdAt,
  });

  static String generateId(String userId, String novelId) =>
      '${userId}_$novelId';

  factory Follow.create({
    required String userId,
    required String novelId,
    DateTime? createdAt,
  }) {
    return Follow(
      id: generateId(userId, novelId),
      userId: userId,
      novelId: novelId,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory Follow.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final userId = (map['userId'] ?? '').toString();
    final novelId = (map['novelId'] ?? '').toString();
    return Follow(
      id: documentId ?? (map['id'] ?? generateId(userId, novelId)).toString(),
      userId: userId,
      novelId: novelId,
      createdAt: DateTimeUtil.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'novelId': novelId,
      'createdAt': DateTimeUtil.toFirestore(createdAt),
    };
  }

  Follow copyWith({
    String? id,
    String? userId,
    String? novelId,
    DateTime? createdAt,
  }) {
    return Follow(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      novelId: novelId ?? this.novelId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
