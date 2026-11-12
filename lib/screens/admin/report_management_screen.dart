import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/utils/date_time_util.dart';
import '../../models/content_report.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';

enum ReportTabFilter { pending, resolved, dismissed, all }

/// Admin screen for reviewing, resolving, or dismissing reader content reports.
class ReportManagementScreen extends StatefulWidget {
  const ReportManagementScreen({super.key});

  @override
  State<ReportManagementScreen> createState() => _ReportManagementScreenState();
}

class _ReportManagementScreenState extends State<ReportManagementScreen> {
  ReportTabFilter _filter = ReportTabFilter.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<AdminProvider>().loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();
    final currentAdminUid = auth.currentUid ?? '';

    final allReports = admin.reports;

    final filteredReports = allReports.where((r) {
      switch (_filter) {
        case ReportTabFilter.pending:
          return r.isPending;
        case ReportTabFilter.resolved:
          return r.isResolved;
        case ReportTabFilter.dismissed:
          return r.isDismissed;
        case ReportTabFilter.all:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Reports'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: admin.loading ? null : _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: admin.loading && allReports.isEmpty
                ? const LoadingState(message: 'Loading reports...')
                : RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: filteredReports.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: EmptyState(
                                icon: Icons.assignment_turned_in_outlined,
                                title: 'No Reports',
                                message: _filter == ReportTabFilter.pending
                                    ? 'No pending content reports to review.'
                                    : 'No reports found for this filter.',
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredReports.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];
                              return _buildReportCard(report, currentAdminUid);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.5)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('Pending', ReportTabFilter.pending),
            const SizedBox(width: 8),
            _filterChip('Resolved', ReportTabFilter.resolved),
            const SizedBox(width: 8),
            _filterChip('Dismissed', ReportTabFilter.dismissed),
            const SizedBox(width: 8),
            _filterChip('All Reports', ReportTabFilter.all),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, ReportTabFilter filter) {
    final selected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) setState(() => _filter = filter);
      },
      selectedColor: AppTheme.accentTeal.withValues(alpha: 0.2),
      side: BorderSide(
        color: selected ? AppTheme.accentTeal : AppTheme.borderDark,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? AppTheme.accentTeal : AppTheme.textMuted,
      ),
    );
  }

  Widget _buildReportCard(ContentReport report, String currentAdminUid) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Target & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _targetIcon(report.targetType),
                            size: 14,
                            color: AppTheme.accentTeal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            report.targetType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ID: ${report.targetId.length > 12 ? "${report.targetId.substring(0, 12)}..." : report.targetId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                _statusBadge(report.status),
              ],
            ),
            const SizedBox(height: 10),

            // Reason
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reason: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.textHighContrast,
                  ),
                ),
                Expanded(
                  child: Text(
                    report.reason,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            if (report.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),
            // Metadata: Reporter, Date
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 13,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Reporter: ${report.reporterId.length > 8 ? "${report.reporterId.substring(0, 8)}..." : report.reporterId}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 14),
                if (report.createdAt != null)
                  Text(
                    DateTimeUtil.formatDate(report.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
              ],
            ),

            if (report.isPending) ...[
              const SizedBox(height: 12),
              const Divider(color: AppTheme.borderDark, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textMuted,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => _handleDismiss(report, currentAdminUid),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Dismiss'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () => _handleResolve(report, currentAdminUid),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Resolve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _targetIcon(String targetType) {
    switch (targetType.toLowerCase()) {
      case 'novel':
        return Icons.menu_book_outlined;
      case 'chapter':
        return Icons.article_outlined;
      case 'comment':
        return Icons.comment_outlined;
      case 'user':
        return Icons.person_outlined;
      default:
        return Icons.flag_outlined;
    }
  }

  Widget _statusBadge(ReportStatus status) {
    Color color;
    switch (status) {
      case ReportStatus.pending:
        color = Colors.amber;
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        break;
      case ReportStatus.dismissed:
        color = AppTheme.textMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Future<void> _handleResolve(
    ContentReport report,
    String currentAdminUid,
  ) async {
    try {
      await context.read<AdminProvider>().resolveReport(
        reportId: report.id,
        adminId: currentAdminUid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0F766E),
          content: Text('Report marked as resolved.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to resolve report: $e'),
        ),
      );
    }
  }

  Future<void> _handleDismiss(
    ContentReport report,
    String currentAdminUid,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dismiss Report?'),
        content: const Text(
          'Dismiss this report without taking punitive action against the target content?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surfaceElevated,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<AdminProvider>().dismissReport(
        reportId: report.id,
        adminId: currentAdminUid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.teal,
          content: Text('Report dismissed.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to dismiss report: $e'),
        ),
      );
    }
  }
}
