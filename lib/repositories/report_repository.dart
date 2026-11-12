import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../models/content_report.dart';

abstract class ReportRepository {
  Future<String> submitReport(ContentReport report);
  Future<List<ContentReport>> getReports({ReportStatus? status});
  Future<void> resolveReport({
    required String reportId,
    required String adminId,
  });
  Future<void> dismissReport({
    required String reportId,
    required String adminId,
  });
  Future<int> countPendingReports();
}

class FirebaseReportRepository implements ReportRepository {
  final FirebaseFirestore _firestore;

  FirebaseReportRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reportsCol =>
      _firestore.collection(FirestoreCollections.reports);

  @override
  Future<String> submitReport(ContentReport report) async {
    try {
      final validTargets = ['novel', 'chapter', 'comment'];
      if (!validTargets.contains(report.targetType.toLowerCase().trim())) {
        throw const ValidationException('Invalid report target type.');
      }
      if (report.targetId.trim().isEmpty) {
        throw const ValidationException('Target ID cannot be empty.');
      }
      if (report.reason.trim().isEmpty) {
        throw const ValidationException('Reason for report is required.');
      }

      final docRef = report.id.isNotEmpty
          ? _reportsCol.doc(report.id)
          : _reportsCol.doc();

      final initialReport = report.copyWith(
        id: docRef.id,
        targetType: report.targetType.toLowerCase().trim(),
        reason: report.reason.trim(),
        description: report.description.trim(),
        status: ReportStatus.pending,
        reviewedAt: null,
        reviewedBy: '',
        createdAt: DateTime.now(),
      );

      final map = initialReport.toMap();
      map['createdAt'] = FieldValue.serverTimestamp();
      map['reviewedAt'] = null;

      await docRef.set(map);
      return docRef.id;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<ContentReport>> getReports({ReportStatus? status}) async {
    try {
      Query<Map<String, dynamic>> query = _reportsCol;
      if (status != null) {
        query = query.where('status', isEqualTo: status.toValue());
      }

      final snapshot = await query.get();
      final list = snapshot.docs
          .map((doc) => ContentReport.fromMap(doc.data(), documentId: doc.id))
          .toList();

      list.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
      return list;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> resolveReport({
    required String reportId,
    required String adminId,
  }) async {
    try {
      await _reportsCol.doc(reportId).update({
        'status': ReportStatus.resolved.toValue(),
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<void> dismissReport({
    required String reportId,
    required String adminId,
  }) async {
    try {
      await _reportsCol.doc(reportId).update({
        'status': ReportStatus.dismissed.toValue(),
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<int> countPendingReports() async {
    try {
      final snapshot = await _reportsCol
          .where('status', isEqualTo: ReportStatus.pending.toValue())
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
