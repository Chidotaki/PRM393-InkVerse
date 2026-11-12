import '../core/utils/date_time_util.dart';

enum NovelStatus {
  ongoing,
  completed,
  hiatus;

  static NovelStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'completed':
        return NovelStatus.completed;
      case 'hiatus':
        return NovelStatus.hiatus;
      case 'ongoing':
      default:
        return NovelStatus.ongoing;
    }
  }

  String toValue() => name;

  String get label {
    switch (this) {
      case NovelStatus.ongoing:
        return 'Ongoing';
      case NovelStatus.completed:
        return 'Completed';
      case NovelStatus.hiatus:
        return 'On Hiatus';
    }
  }
}

enum NovelVisibility {
  draft,
  published,
  hidden;

  static NovelVisibility fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'published':
        return NovelVisibility.published;
      case 'hidden':
        return NovelVisibility.hidden;
      case 'draft':
      default:
        return NovelVisibility.draft;
    }
  }

  String toValue() => name;
}

class Novel {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final String coverUrl;
  final List<String> genres;
  final NovelStatus status;
  final NovelVisibility visibility;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final int chapterCount;
  final int viewCount;
  final int followerCount;

  const Novel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    this.description = '',
    this.coverUrl = '',
    this.genres = const [],
    this.status = NovelStatus.ongoing,
    this.visibility = NovelVisibility.draft,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.chapterCount = 0,
    this.viewCount = 0,
    this.followerCount = 0,
  });

  bool get isPublished => visibility == NovelVisibility.published;
  bool get isDraft => visibility == NovelVisibility.draft;
  bool get isHidden => visibility == NovelVisibility.hidden;

  factory Novel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final rawGenres = map['genres'];
    List<String> parsedGenres = [];
    if (rawGenres is List) {
      parsedGenres = rawGenres.map((e) => e.toString()).toList();
    }

    return Novel(
      id: (documentId ?? map['id'] ?? '').toString(),
      authorId: (map['authorId'] ?? '').toString(),
      authorName: (map['authorName'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      coverUrl: (map['coverUrl'] ?? '').toString(),
      genres: parsedGenres,
      status: NovelStatus.fromString(map['status']?.toString()),
      visibility: NovelVisibility.fromString(map['visibility']?.toString()),
      createdAt: DateTimeUtil.parse(map['createdAt']),
      updatedAt: DateTimeUtil.parse(map['updatedAt']),
      publishedAt: DateTimeUtil.parse(map['publishedAt']),
      chapterCount: (map['chapterCount'] as num?)?.toInt() ?? 0,
      viewCount: (map['viewCount'] as num?)?.toInt() ?? 0,
      followerCount: (map['followerCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'genres': genres,
      'status': status.toValue(),
      'visibility': visibility.toValue(),
      'createdAt': DateTimeUtil.toFirestore(createdAt),
      'updatedAt': DateTimeUtil.toFirestore(updatedAt),
      'publishedAt': DateTimeUtil.toFirestore(publishedAt),
      'chapterCount': chapterCount,
      'viewCount': viewCount,
      'followerCount': followerCount,
    };
  }

  Novel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? title,
    String? description,
    String? coverUrl,
    List<String>? genres,
    NovelStatus? status,
    NovelVisibility? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? chapterCount,
    int? viewCount,
    int? followerCount,
  }) {
    return Novel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      chapterCount: chapterCount ?? this.chapterCount,
      viewCount: viewCount ?? this.viewCount,
      followerCount: followerCount ?? this.followerCount,
    );
  }
}
