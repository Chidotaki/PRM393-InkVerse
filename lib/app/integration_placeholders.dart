import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/author_provider.dart';
import '../providers/library_provider.dart';
import '../providers/novel_provider.dart';
import '../providers/reading_provider.dart';

// ============================================================================
// TEMPORARY INTEGRATION PLACEHOLDERS
//
// These screens are intentionally minimal placeholders so the core application
// compiles and can be smoke-tested end-to-end.
//
// They will be replaced when teammate branches are merged:
// - Member 2: feature/reader-ui (Reader Home, Discover, Novel Detail, Reading, Library, Profile)
// - Member 3: feature/author-admin-ui (Author Dashboard, My Novels, Forms, Admin Screens)
//
// DO NOT BUILD POLISHED SCREENS HERE to avoid git conflicts with teammates.
// ============================================================================

/// Common helper scaffold for placeholders
Widget _placeholderScaffold({
  required BuildContext context,
  required String title,
  required String owner,
  required String branch,
  required String message,
  List<Widget>? actions,
  Widget? bodyContent,
}) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () => context.read<AuthProvider>().logout(),
            ),
          ],
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dashboard_customize_outlined,
                size: 48,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '// TEMPORARY INTEGRATION PLACEHOLDER',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Module Owner: $owner\nTarget Branch: $branch',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            if (bodyContent != null) ...[
              const SizedBox(height: 20),
              bodyContent,
            ],
          ],
        ),
      ),
    ),
  );
}

// ----------------------------------------------------------------------------
// READER PLACEHOLDERS (Member 2 - feature/reader-ui)
// ----------------------------------------------------------------------------

class ReaderHomePlaceholderScreen extends StatelessWidget {
  const ReaderHomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final novelProvider = context.watch<NovelProvider>();

    return _placeholderScaffold(
      context: context,
      title: 'Reader Home Screen',
      owner: 'Member 2 (Reader UI)',
      branch: 'feature/reader-ui',
      message: 'Reader Home UI will be integrated from feature/reader-ui.',
      bodyContent: Column(
        children: [
          Text(
            'Welcome, ${auth.currentUser?.fullName ?? 'Reader'}! (${auth.currentUser?.role.name.toUpperCase()})',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            '${novelProvider.visibleNovels.length} published novels available in NovelProvider.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.explore),
                label: const Text('Discover'),
                onPressed: () => context.go('/discover'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.bookmarks),
                label: const Text('Library'),
                onPressed: () => context.go('/library'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('Profile'),
                onPressed: () => context.go('/profile'),
              ),
              if (auth.isAuthor || auth.isAdmin)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Author Studio'),
                  onPressed: () => context.go('/author'),
                ),
              if (auth.isAdmin)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Admin Console'),
                  onPressed: () => context.go('/admin'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DiscoverPlaceholderScreen extends StatelessWidget {
  const DiscoverPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    return _placeholderScaffold(
      context: context,
      title: 'Discover Novels',
      owner: 'Member 2 (Reader UI)',
      branch: 'feature/reader-ui',
      message: 'Discover UI will be integrated from feature/reader-ui.',
      bodyContent: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
          const SizedBox(height: 12),
          ...novelProvider.visibleNovels.map(
            (novel) => Card(
              child: ListTile(
                title: Text(novel.title),
                subtitle: Text(
                  '${novel.authorName} • ${novel.genres.join(', ')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/novel/${novel.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NovelDetailPlaceholderScreen extends StatelessWidget {
  final String novelId;
  const NovelDetailPlaceholderScreen({super.key, required this.novelId});

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    final auth = context.watch<AuthProvider>();

    final novel = novelProvider.allNovels.firstWhere(
      (n) => n.id == novelId,
      orElse: () => novelProvider.visibleNovels.firstWhere(
        (n) => n.id == novelId,
        orElse: () => Novel(
          id: novelId,
          authorId: '',
          authorName: '',
          title: 'Novel ($novelId)',
        ),
      ),
    );

    final isFollowing = libraryProvider.isFollowing(novelId);

    return _placeholderScaffold(
      context: context,
      title: novel.title,
      owner: 'Member 2 (Reader UI)',
      branch: 'feature/reader-ui',
      message: 'Novel Detail UI will be integrated from feature/reader-ui.',
      bodyContent: Column(
        children: [
          Text(novel.description, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: Icon(isFollowing ? Icons.check : Icons.favorite_border),
                label: Text(isFollowing ? 'Following' : 'Follow'),
                onPressed: () {
                  final uid = auth.currentUid;
                  if (uid != null) {
                    libraryProvider.toggleFollow(uid, novelId);
                  }
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text('Read Chapter 1'),
                onPressed: () {
                  // Navigate to reading screen
                  context.go('/novel/$novelId/chapter/chap_1_1');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class ReadingPlaceholderScreen extends StatefulWidget {
  final String novelId;
  final String chapterId;

  const ReadingPlaceholderScreen({
    super.key,
    required this.novelId,
    required this.chapterId,
  });

  @override
  State<ReadingPlaceholderScreen> createState() =>
      _ReadingPlaceholderScreenState();
}

class _ReadingPlaceholderScreenState extends State<ReadingPlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<ReadingProvider>().loadChapter(
        novelId: widget.novelId,
        chapterId: widget.chapterId,
        userId: auth.currentUid,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final reading = context.watch<ReadingProvider>();

    return _placeholderScaffold(
      context: context,
      title: reading.currentChapter?.title ?? 'Reading Screen',
      owner: 'Member 2 (Reader UI)',
      branch: 'feature/reader-ui',
      message: 'Reading UI will be integrated from feature/reader-ui.',
      bodyContent: Column(
        children: [
          if (reading.loading)
            const CircularProgressIndicator()
          else if (reading.currentChapter != null) ...[
            Text(
              'Chapter ${reading.currentChapter!.chapterNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reading.currentChapter!.content,
                style: TextStyle(
                  fontSize: reading.fontSize,
                  height: reading.lineSpacing,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: reading.hasPreviousChapter
                    ? () => reading.goToPreviousChapter()
                    : null,
                child: const Text('Previous Chapter'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: reading.hasNextChapter
                    ? () => reading.goToNextChapter()
                    : null,
                child: const Text('Next Chapter'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/novel/${widget.novelId}'),
            child: const Text('Back to Novel'),
          ),
        ],
      ),
    );
  }
}

class LibraryPlaceholderScreen extends StatefulWidget {
  const LibraryPlaceholderScreen({super.key});

  @override
  State<LibraryPlaceholderScreen> createState() =>
      _LibraryPlaceholderScreenState();
}

class _LibraryPlaceholderScreenState extends State<LibraryPlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUid;
      if (uid != null) {
        context.read<LibraryProvider>().loadLibrary(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return _placeholderScaffold(
      context: context,
      title: 'My Library',
      owner: 'Member 2 (Reader UI)',
      branch: 'feature/reader-ui',
      message: 'Library UI will be integrated from feature/reader-ui.',
      bodyContent: Column(
        children: [
          Text(
            'Followed Novels: ${library.followedNovelIds.length} | Bookmarks: ${library.bookmarks.length} | History: ${library.readingHistory.length}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => context.go('/bookmarks'),
                child: const Text('View Bookmarks'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => context.go('/history'),
                child: const Text('Reading History'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class BookmarksPlaceholderScreen extends StatelessWidget {
  const BookmarksPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _placeholderScaffold(
      context: context,
      title: 'Bookmarks Screen',
      owner: 'Member 2 (Reader UI)',
      branch: 'feature/reader-ui',
      message: 'Bookmarks UI will be integrated from feature/reader-ui.',
      bodyContent: ElevatedButton(
        onPressed: () => context.go('/library'),
        child: const Text('Back to Library'),
      ),
    );
  }
}

class ReadingHistoryPlaceholderScreen extends StatelessWidget {
  const ReadingHistoryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _placeholderScaffold(
      context: context,
      title: 'Reading History Screen',
      owner: 'Member 2 (Reader UI)',
      branch: 'feature/reader-ui',
      message: 'Reading History UI will be integrated from feature/reader-ui.',
      bodyContent: ElevatedButton(
        onPressed: () => context.go('/library'),
        child: const Text('Back to Library'),
      ),
    );
  }
}

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return _placeholderScaffold(
      context: context,
      title: 'User Profile Screen',
      owner: 'Member 2 (Reader UI)',
      branch: 'feature/reader-ui',
      message: 'Profile UI will be integrated from feature/reader-ui.',
      bodyContent: Column(
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'U',
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.fullName ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Chip(
            label: Text(
              'Role: ${user?.role.name.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // Become Author Button (Section 26: Reader -> Author transition)
          if (auth.isReader) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              icon: const Icon(Icons.drive_file_rename_outline),
              label: auth.submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text('Become an Author'),
              onPressed: auth.submitting
                  ? null
                  : () async {
                      try {
                        await auth.becomeAuthor();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Congratulations! You are now an Author.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// AUTHOR PLACEHOLDERS (Member 3 - feature/author-admin-ui)
// ----------------------------------------------------------------------------

class AuthorDashboardPlaceholderScreen extends StatefulWidget {
  const AuthorDashboardPlaceholderScreen({super.key});

  @override
  State<AuthorDashboardPlaceholderScreen> createState() =>
      _AuthorDashboardPlaceholderScreenState();
}

class _AuthorDashboardPlaceholderScreenState
    extends State<AuthorDashboardPlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUid;
      if (uid != null) {
        context.read<AuthorProvider>().loadMyNovels(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final author = context.watch<AuthorProvider>();

    return _placeholderScaffold(
      context: context,
      title: 'Author Studio Dashboard',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message:
          'Author Studio UI will be integrated from feature/author-admin-ui.',
      bodyContent: Column(
        children: [
          Text(
            'My Authored Novels: ${author.myNovels.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Novel'),
                onPressed: () => context.go('/author/novel/new'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.book),
                label: const Text('My Novels List'),
                onPressed: () => context.go('/author/novels'),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Reader Home'),
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyNovelsPlaceholderScreen extends StatelessWidget {
  const MyNovelsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final author = context.watch<AuthorProvider>();

    return _placeholderScaffold(
      context: context,
      title: 'My Authored Novels',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message: 'My Novels UI will be integrated from feature/author-admin-ui.',
      bodyContent: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.go('/author'),
            child: const Text('Back to Author Studio'),
          ),
          const SizedBox(height: 12),
          ...author.myNovels.map(
            (novel) => Card(
              child: ListTile(
                title: Text(novel.title),
                subtitle: Text(
                  'Status: ${novel.status.label} • Visibility: ${novel.visibility.name}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/author/novel/${novel.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NovelFormPlaceholderScreen extends StatelessWidget {
  final String? novelId;
  const NovelFormPlaceholderScreen({super.key, this.novelId});

  @override
  Widget build(BuildContext context) {
    return _placeholderScaffold(
      context: context,
      title: novelId == null ? 'Create Novel Form' : 'Edit Novel Form',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message: 'Novel Form UI will be integrated from feature/author-admin-ui.',
      bodyContent: ElevatedButton(
        onPressed: () => context.go('/author'),
        child: const Text('Back to Author Studio'),
      ),
    );
  }
}

class ChapterManagementPlaceholderScreen extends StatelessWidget {
  final String novelId;
  const ChapterManagementPlaceholderScreen({super.key, required this.novelId});

  @override
  Widget build(BuildContext context) {
    return _placeholderScaffold(
      context: context,
      title: 'Chapter Management',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message: 'Chapter Management UI will be integrated from feature/author-admin-ui.',
      bodyContent: ElevatedButton(
        onPressed: () => context.go('/author/novels'),
        child: const Text('Back to My Novels'),
      ),
    );
  }
}

class ChapterFormPlaceholderScreen extends StatelessWidget {
  final String novelId;
  final String? chapterId;

  const ChapterFormPlaceholderScreen({
    super.key,
    required this.novelId,
    this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return _placeholderScaffold(
      context: context,
      title: chapterId == null ? 'Create Chapter Form' : 'Edit Chapter Form',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message:
          'Chapter Form UI will be integrated from feature/author-admin-ui.',
      bodyContent: ElevatedButton(
        onPressed: () => context.go('/author/novel/$novelId/chapters'),
        child: const Text('Back to Chapters'),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// ADMIN PLACEHOLDERS (Member 3 - feature/author-admin-ui)
// ----------------------------------------------------------------------------

class AdminDashboardPlaceholderScreen extends StatefulWidget {
  const AdminDashboardPlaceholderScreen({super.key});

  @override
  State<AdminDashboardPlaceholderScreen> createState() =>
      _AdminDashboardPlaceholderScreenState();
}

class _AdminDashboardPlaceholderScreenState
    extends State<AdminDashboardPlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final m = admin.metrics;

    return _placeholderScaffold(
      context: context,
      title: 'Admin Control Center',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message:
          'Admin Dashboard UI will be integrated from feature/author-admin-ui.',
      bodyContent: Column(
        children: [
          Text(
            'Platform Overview:\n'
            'Users: ${m.totalUsers} (Authors: ${m.totalAuthors}) | '
            'Novels: ${m.totalNovels} (Published: ${m.publishedNovels})\n'
            'Pending Reports: ${m.pendingReports} | Comments: ${m.totalComments}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('User Management'),
                onPressed: () => context.go('/admin/users'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text('Novel Moderation'),
                onPressed: () => context.go('/admin/novels'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.flag),
                label: const Text('Reports'),
                onPressed: () => context.go('/admin/reports'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.category),
                label: const Text('Genres'),
                onPressed: () => context.go('/admin/genres'),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Reader Home'),
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserManagementPlaceholderScreen extends StatelessWidget {
  const UserManagementPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _placeholderScaffold(
      context: context,
      title: 'User Management Screen',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message:
          'User Management UI will be integrated from feature/author-admin-ui.',
      bodyContent: ElevatedButton(
        onPressed: () => context.go('/admin'),
        child: const Text('Back to Admin Dashboard'),
      ),
    );
  }
}

class NovelModerationPlaceholderScreen extends StatelessWidget {
  const NovelModerationPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _placeholderScaffold(
      context: context,
      title: 'Novel Moderation Screen',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message: 'Novel Moderation UI will be integrated from feature/author-admin-ui.',
      bodyContent: ElevatedButton(
        onPressed: () => context.go('/admin'),
        child: const Text('Back to Admin Dashboard'),
      ),
    );
  }
}

class ReportManagementPlaceholderScreen extends StatelessWidget {
  const ReportManagementPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _placeholderScaffold(
      context: context,
      title: 'Content Report Management',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message: 'Report Management UI will be integrated from feature/author-admin-ui.',
      bodyContent: ElevatedButton(
        onPressed: () => context.go('/admin'),
        child: const Text('Back to Admin Dashboard'),
      ),
    );
  }
}

class GenreManagementPlaceholderScreen extends StatelessWidget {
  const GenreManagementPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _placeholderScaffold(
      context: context,
      title: 'Genre Management Screen',
      owner: 'Member 3 (Author & Admin UI)',
      branch: 'feature/author-admin-ui',
      message: 'Genre Management UI will be integrated from feature/author-admin-ui.',
      bodyContent: ElevatedButton(
        onPressed: () => context.go('/admin'),
        child: const Text('Back to Admin Dashboard'),
      ),
    );
  }
}
