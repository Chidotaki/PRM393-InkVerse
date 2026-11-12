import '../core/utils/date_time_util.dart';

enum ReportStatus {
  pending,
  resolved,
  dismissed;

  static ReportStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      case 'pending':
      default:
        return ReportStatus.pending;
    }
  }

  String toValue() => name;

  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }
}

class ContentReport {
  final String id;
  final String reporterId;
  final String targetType; // 'novel', 'chapter', 'comment'
  final String targetId;
  final String reason;
  final String description;
  final ReportStatus status;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final String reviewedBy;

  const ContentReport({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description = '',
    this.status = ReportStatus.pending,
    this.createdAt,
    this.reviewedAt,
    this.reviewedBy = '',
  });

  bool get isPending => status == ReportStatus.pending;
  bool get isResolved => status == ReportStatus.resolved;
  bool get isDismissed => status == ReportStatus.dismissed;

  factory ContentReport.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return ContentReport(
      id: (documentId ?? map['id'] ?? '').toString(),
      reporterId: (map['reporterId'] ?? '').toString(),
      targetType: (map['targetType'] ?? 'novel').toString(),
      targetId: (map['targetId'] ?? '').toString(),
      reason: (map['reason'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      status: ReportStatus.fromString(map['status']?.toString()),
      createdAt: DateTimeUtil.parse(map['createdAt']),
      reviewedAt: DateTimeUtil.parse(map['reviewedAt']),
      reviewedBy: (map['reviewedBy'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
      'description': description,
      'status': status.toValue(),
      'createdAt': DateTimeUtil.toFirestore(createdAt),
      'reviewedAt': DateTimeUtil.toFirestore(reviewedAt),
      'reviewedBy': reviewedBy,
    };
  }

  ContentReport copyWith({
    String? id,
    String? reporterId,
    String? targetType,
    String? targetId,
    String? reason,
    String? description,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return ContentReport(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}
