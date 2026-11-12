import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/utils/date_time_util.dart';
import '../../models/app_user.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';

enum UserRoleFilter { all, reader, author, admin }

/// Admin console screen for searching, filtering, and activating/disabling user accounts.
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  UserRoleFilter _roleFilter = UserRoleFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<AdminProvider>().loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();
    final currentAdminUid = auth.currentUid ?? '';

    final allUsers = admin.users;

    // Filter by search query and role
    final filteredUsers = allUsers.where((u) {
      if (_searchQuery.isNotEmpty) {
        final nameMatch = u.fullName.toLowerCase().contains(_searchQuery);
        final emailMatch = u.email.toLowerCase().contains(_searchQuery);
        if (!nameMatch && !emailMatch) return false;
      }

      switch (_roleFilter) {
        case UserRoleFilter.all:
          return true;
        case UserRoleFilter.reader:
          return u.role == UserRole.reader;
        case UserRoleFilter.author:
          return u.role == UserRole.author;
        case UserRoleFilter.admin:
          return u.role == UserRole.admin;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
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
          // Search & Filter Header
          _buildFilterBar(),

          // Users List
          Expanded(
            child: admin.loading && allUsers.isEmpty
                ? const LoadingState(message: 'Loading users...')
                : RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: filteredUsers.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: EmptyState(
                                icon: Icons.person_search_outlined,
                                title: 'No Users Found',
                                message: _searchQuery.isNotEmpty
                                    ? 'No accounts match "$_searchQuery".'
                                    : 'No accounts in this category.',
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredUsers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return _buildUserCard(
                                context,
                                user,
                                currentAdminUid,
                              );
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          // Search input
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Role Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _roleChip('All Users', UserRoleFilter.all),
                const SizedBox(width: 8),
                _roleChip('Readers', UserRoleFilter.reader),
                const SizedBox(width: 8),
                _roleChip('Authors', UserRoleFilter.author),
                const SizedBox(width: 8),
                _roleChip('Admins', UserRoleFilter.admin),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String label, UserRoleFilter filter) {
    final selected = _roleFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) setState(() => _roleFilter = filter);
      },
      selectedColor: AppTheme.accentCyan.withValues(alpha: 0.2),
      side: BorderSide(
        color: selected ? AppTheme.accentCyan : AppTheme.borderDark,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? AppTheme.accentCyan : AppTheme.textMuted,
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    AppUser user,
    String currentAdminUid,
  ) {
    final isSelf = user.uid == currentAdminUid;

    return Card(
      elevation: 0,
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: _roleColor(user.role).withValues(alpha: 0.15),
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _roleColor(user.role),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHighContrast,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelf) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentTeal,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _roleBadge(user.role),
                      _activeBadge(user.isActive),
                      if (user.createdAt != null)
                        Text(
                          'Joined ${DateTimeUtil.formatDate(user.createdAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Toggle Active Button
            if (user.isActive)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: () =>
                    _handleToggleActive(user, false, currentAdminUid),
                child: const Text('Disable'),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: () =>
                    _handleToggleActive(user, true, currentAdminUid),
                child: const Text('Enable'),
              ),
          ],
        ),
      ),
    );
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.accentPurple;
      case UserRole.author:
        return AppTheme.accentTeal;
      case UserRole.reader:
        return AppTheme.accentCyan;
    }
  }

  Widget _roleBadge(UserRole role) {
    final color = _roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        role.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _activeBadge(bool isActive) {
    final color = isActive ? Colors.green : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isActive ? 'Active' : 'Disabled',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Future<void> _handleToggleActive(
    AppUser user,
    bool makeActive,
    String currentAdminUid,
  ) async {
    if (!makeActive && user.uid == currentAdminUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Administrators cannot disable their own account.'),
        ),
      );
      return;
    }

    final actionText = makeActive ? 'Enable' : 'Disable';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionText Account?'),
        content: Text(
          makeActive
              ? 'Re-enable account for "${user.fullName}"? They will regain full access.'
              : 'Disable account for "${user.fullName}"? They will be locked out and redirected to account disabled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: makeActive ? Colors.green : Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(actionText),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<AdminProvider>().setUserActive(
        uid: user.uid,
        isActive: makeActive,
        currentAdminUid: currentAdminUid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal[800],
          content: Text('User account ${makeActive ? 'enabled' : 'disabled'}.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Failed to update user status: $e'),
        ),
      );
    }
  }
}
