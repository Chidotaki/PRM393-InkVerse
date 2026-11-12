import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/reading_provider.dart';
import '../../widgets/user_avatar.dart';

/// Account Profile screen presenting reader identity, role transitions (Become Author / Studio / Admin),
/// library statistics, profile editing, and reading preferences.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final library = context.watch<LibraryProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final user = auth.currentUser;
    final displayName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : (user?.email.split('@').first ?? 'InkVerse Reader');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _showSignOutDialog(context, auth),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                UserAvatar(
                  name: user?.fullName,
                  email: user?.email,
                  avatarUrl: user?.avatarUrl,
                  radius: 44,
                ),
                const SizedBox(height: 14),

                // Name & Email
                Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),

                // Role Badge
                _buildRoleBadge(context, user?.role ?? UserRole.reader),
                const SizedBox(height: 16),

                // Bio
                if (user?.bio != null && user!.bio.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      user.bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ),

                // Edit Profile Button
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Profile'),
                  onPressed: () => _showEditProfileDialog(context, auth, user),
                ),
                const SizedBox(height: 24),

                // Stats Row Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        '${library.followedNovelIds.length}',
                        'Following',
                        Icons.bookmark_outline,
                        () => context.go(AppRoutes.library),
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      _buildStatItem(
                        context,
                        '${library.bookmarks.length}',
                        'Bookmarks',
                        Icons.collections_bookmark_outlined,
                        () => context.go(AppRoutes.library),
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      _buildStatItem(
                        context,
                        '${library.readingHistory.length}',
                        'History',
                        Icons.history,
                        () => context.go(AppRoutes.library),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Role Action Cards
                if (auth.isReader)
                  _buildBecomeAuthorCard(context, auth)
                else if (auth.isAuthor)
                  _buildRoleShortcutCard(
                    context,
                    title: 'Author Studio',
                    subtitle:
                        'Manage your novels, drafts, and published chapters',
                    icon: Icons.edit_note,
                    buttonLabel: 'Open Author Studio',
                    accentColor: Colors.teal,
                    onTap: () => context.push(AppRoutes.author),
                  ),

                if (auth.isAdmin) ...[
                  const SizedBox(height: 12),
                  _buildRoleShortcutCard(
                    context,
                    title: 'Admin Control Center',
                    subtitle:
                        'Moderate content, manage genres, and oversee users',
                    icon: Icons.admin_panel_settings,
                    buttonLabel: 'Open Admin Console',
                    accentColor: Colors.purple,
                    onTap: () => context.push(AppRoutes.admin),
                  ),
                ],
                const SizedBox(height: 20),

                // Additional Settings Actions
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(Icons.format_size),
                  title: const Text('Reading Preferences'),
                  subtitle: const Text(
                    'Font size, line spacing, reading theme',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPreferencesDialog(context),
                ),
                const SizedBox(height: 8),

                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(Icons.logout, color: colorScheme.error),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: () => _showSignOutDialog(context, auth),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context, UserRole role) {
    Color bg;
    Color fg;
    String label;

    switch (role) {
      case UserRole.admin:
        bg = const Color(0xFF581C87);
        fg = const Color(0xFFD8B4FE);
        label = 'ADMINISTRATOR';
        break;
      case UserRole.author:
        bg = const Color(0xFF115E59);
        fg = const Color(0xFF5EEAD4);
        label = 'PUBLISHED AUTHOR';
        break;
      case UserRole.reader:
        bg = const Color(0xFF1E293B);
        fg = const Color(0xFF94A3B8);
        label = 'READER';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBecomeAuthorCard(BuildContext context, AuthProvider auth) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.draw_outlined, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Text(
                'Ready to Share Your Stories?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Transition to an Author account to create novels, publish serialized chapters, and connect directly with readers.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.tealAccent,
                side: const BorderSide(color: Colors.teal),
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Become an Author'),
              onPressed: () => _confirmBecomeAuthor(context, auth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleShortcutCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonLabel,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: onTap,
            child: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _confirmBecomeAuthor(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Become an InkVerse Author'),
        content: const Text(
          'This will upgrade your account role to Author, granting full access to the Author Studio where you can write and serialize original novels. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await auth.becomeAuthor();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Congratulations! You are now an Author.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    AuthProvider auth,
    AppUser? user,
  ) {
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final bioCtrl = TextEditingController(text: user?.bio ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(labelText: 'Short Bio'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.updateProfile(
                fullName: nameCtrl.text.trim(),
                bio: bioCtrl.text.trim(),
                avatarUrl: user?.avatarUrl ?? '',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully.'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPreferencesDialog(BuildContext context) {
    final reading = context.read<ReadingProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reading Preferences'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Theme: ${reading.readingTheme.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Default Font Size: ${reading.fontSize.toInt()}pt'),
            const SizedBox(height: 8),
            Text('Line Spacing: ${reading.lineSpacing.toStringAsFixed(1)}'),
            const SizedBox(height: 16),
            const Text(
              'You can adjust these settings while reading any chapter via the typography icon in the reader header.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of InkVerse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
