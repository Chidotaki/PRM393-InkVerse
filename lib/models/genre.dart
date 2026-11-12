import '../core/utils/date_time_util.dart';

/// Represents a literary genre / category.
class Genre {
  final String id;
  final String name;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Genre({
    required this.id,
    required this.name,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Genre.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Genre(
      id: (documentId ?? map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      isActive: map['isActive'] is bool ? map['isActive'] as bool : true,
      createdAt: DateTimeUtil.parse(map['createdAt']),
      updatedAt: DateTimeUtil.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'createdAt': DateTimeUtil.toFirestore(createdAt),
      'updatedAt': DateTimeUtil.toFirestore(updatedAt),
    };
  }

  Genre copyWith({
    String? id,
    String? name,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Genre(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
