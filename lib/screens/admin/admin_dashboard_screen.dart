import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_state.dart';

/// Admin Control Center overview dashboard with platform metrics and quick navigation.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<AdminProvider>().loadDashboardMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();
    final metrics = admin.metrics;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Control Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: admin.loading ? null : _loadData,
          ),
          IconButton(
            tooltip: 'Reader Home',
            icon: const Icon(Icons.explore_outlined),
            onPressed: () => context.go(AppRoutes.home),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: admin.loading && metrics.totalUsers == 0
          ? const LoadingState(message: 'Loading platform metrics...')
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Banner
                        _buildHeaderBanner(context),
                        const SizedBox(height: 24),

                        // Metrics Section
                        Text(
                          'Platform Metrics',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHighContrast,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildMetricsGrid(context, metrics),
                        const SizedBox(height: 28),

                        // Control Modules Section
                        Text(
                          'Administration Modules',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHighContrast,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildModulesGrid(context, metrics.pendingReports),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentPurple.withValues(alpha: 0.15),
            AppTheme.accentTeal.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              size: 32,
              color: AppTheme.accentPurple,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'InkVerse Platform Administration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHighContrast,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage user accounts, moderate serial novel content, handle reports, and curate genres.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    AdminDashboardMetrics metrics,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final count = isWide ? 3 : 2;

        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 1.8 : 1.4,
          children: [
            _metricCard(
              'Total Users',
              '${metrics.totalUsers}',
              Icons.people_outline,
              AppTheme.accentCyan,
            ),
            _metricCard(
              'Authors',
              '${metrics.totalAuthors}',
              Icons.edit_note_outlined,
              AppTheme.accentTeal,
            ),
            _metricCard(
              'Total Novels',
              '${metrics.totalNovels}',
              Icons.menu_book_outlined,
              AppTheme.accentPurple,
            ),
            _metricCard(
              'Published Novels',
              '${metrics.publishedNovels}',
              Icons.check_circle_outline,
              Colors.green,
            ),
            _metricCard(
              'Pending Reports',
              '${metrics.pendingReports}',
              Icons.flag_outlined,
              metrics.pendingReports > 0 ? Colors.redAccent : Colors.amber,
            ),
            _metricCard(
              'Comments',
              '${metrics.totalComments}',
              Icons.comment_outlined,
              Colors.blueGrey.shade300,
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid(BuildContext context, int pendingReports) {
    final modules = [
      _ModuleItem(
        title: 'User Management',
        description:
            'View accounts, filter by role, and manage user active status.',
        icon: Icons.manage_accounts_outlined,
        color: AppTheme.accentCyan,
        route: AppRoutes.adminUsers,
      ),
      _ModuleItem(
        title: 'Novel Moderation',
        description: 'Review published catalog, hide violating titles, or restore content.',
        icon: Icons.auto_stories_outlined,
        color: AppTheme.accentTeal,
        route: AppRoutes.adminNovels,
      ),
      _ModuleItem(
        title: 'Content Reports',
        description:
            'Review reader reports for novels, chapters, comments, or users.',
        icon: Icons.report_problem_outlined,
        color: pendingReports > 0 ? Colors.redAccent : Colors.amber,
        route: AppRoutes.adminReports,
        badgeText: pendingReports > 0 ? '$pendingReports pending' : null,
      ),
      _ModuleItem(
        title: 'Genre Taxonomy',
        description: 'Curate official catalog genres, rename labels, and manage taxonomy.',
        icon: Icons.category_outlined,
        color: AppTheme.accentPurple,
        route: AppRoutes.adminGenres,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 2 : 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isWide ? 2.6 : 3.0,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final item = modules[index];
            return _buildModuleCard(context, item);
          },
        );
      },
    );
  }

  Widget _buildModuleCard(BuildContext context, _ModuleItem item) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderDark),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(item.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 24, color: item.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textHighContrast,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              item.badgeText!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final String? badgeText;

  _ModuleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    this.badgeText,
  });
}
