import '../core/utils/date_time_util.dart';

enum ChapterStatus {
  draft,
  published;

  static ChapterStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'published':
        return ChapterStatus.published;
      case 'draft':
      default:
        return ChapterStatus.draft;
    }
  }

  String toValue() => name;

  String get label {
    switch (this) {
      case ChapterStatus.draft:
        return 'Draft';
      case ChapterStatus.published:
        return 'Published';
    }
  }
}

class Chapter {
  final String id;
  final String novelId;
  final String authorId;
  final String title;
  final int chapterNumber;
  final String content;
  final ChapterStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final int wordCount;

  const Chapter({
    required this.id,
    required this.novelId,
    required this.authorId,
    required this.title,
    required this.chapterNumber,
    required this.content,
    this.status = ChapterStatus.draft,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.wordCount = 0,
  });

  bool get isPublished => status == ChapterStatus.published;
  bool get isDraft => status == ChapterStatus.draft;

  /// Helper to calculate word count accurately from content string.
  static int calculateWordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  factory Chapter.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final content = (map['content'] ?? '').toString();
    final wordCount =
        (map['wordCount'] as num?)?.toInt() ?? calculateWordCount(content);

    return Chapter(
      id: (documentId ?? map['id'] ?? '').toString(),
      novelId: (map['novelId'] ?? '').toString(),
      authorId: (map['authorId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      chapterNumber: (map['chapterNumber'] as num?)?.toInt() ?? 1,
      content: content,
      status: ChapterStatus.fromString(map['status']?.toString()),
      createdAt: DateTimeUtil.parse(map['createdAt']),
      updatedAt: DateTimeUtil.parse(map['updatedAt']),
      publishedAt: DateTimeUtil.parse(map['publishedAt']),
      wordCount: wordCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'novelId': novelId,
      'authorId': authorId,
      'title': title,
      'chapterNumber': chapterNumber,
      'content': content,
      'status': status.toValue(),
      'createdAt': DateTimeUtil.toFirestore(createdAt),
      'updatedAt': DateTimeUtil.toFirestore(updatedAt),
      'publishedAt': DateTimeUtil.toFirestore(publishedAt),
      'wordCount': wordCount,
    };
  }

  Chapter copyWith({
    String? id,
    String? novelId,
    String? authorId,
    String? title,
    int? chapterNumber,
    String? content,
    ChapterStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? wordCount,
  }) {
    final newContent = content ?? this.content;
    return Chapter(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      content: newContent,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      wordCount:
          wordCount ??
          (content != null ? calculateWordCount(newContent) : this.wordCount),
    );
  }
}
