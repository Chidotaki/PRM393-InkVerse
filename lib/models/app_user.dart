import '../core/utils/date_time_util.dart';

/// Available user roles in InkVerse.
enum UserRole {
  reader,
  author,
  admin;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase().trim()) {
      case 'admin':
        return UserRole.admin;
      case 'author':
        return UserRole.author;
      case 'reader':
      default:
        // Unknown or null role safely defaults to reader, NEVER admin
        return UserRole.reader;
    }
  }

  String toValue() => name;
}

/// AppUser represents the user profile stored in Firestore `users/{uid}`.
class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final UserRole role;
  final String avatarUrl;
  final String bio;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.role = UserRole.reader,
    this.avatarUrl = '',
    this.bio = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isReader => role == UserRole.reader;
  bool get isAuthor => role == UserRole.author;
  bool get isAdmin => role == UserRole.admin;
  bool get canCreateNovels => isAuthor || isAdmin;

  factory AppUser.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return AppUser(
      uid: (documentId ?? map['uid'] ?? '').toString(),
      fullName: (map['fullName'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: UserRole.fromString(map['role']?.toString()),
      avatarUrl: (map['avatarUrl'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
      isActive: map['isActive'] is bool ? map['isActive'] as bool : true,
      createdAt: DateTimeUtil.parse(map['createdAt']),
      updatedAt: DateTimeUtil.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role.toValue(),
      'avatarUrl': avatarUrl,
      'bio': bio,
      'isActive': isActive,
      'createdAt': DateTimeUtil.toFirestore(createdAt),
      'updatedAt': DateTimeUtil.toFirestore(updatedAt),
    };
  }

  AppUser copyWith({
    String? uid,
    String? fullName,
    String? email,
    UserRole? role,
    String? avatarUrl,
    String bio = '',
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio.isNotEmpty ? bio : this.bio,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          role == other.role &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      uid.hashCode ^ email.hashCode ^ role.hashCode ^ isActive.hashCode;
}
