# InkVerse – Team Integration Data Contracts

This document specifies the exact data contracts, provider methods, and routing contracts for:
- **Member 2 (Reader UI)**: `feature/reader-ui`
- **Member 3 (Author & Admin UI)**: `feature/author-admin-ui`

UI members **never need to touch FirebaseFirestore directly**. All data, queries, filtering, and mutations are handled through Providers.

---

## 1. Contracts for Member 2 (Reader UI)

### A. Authentication & Current User (`AuthProvider`)
Access via `context.watch<AuthProvider>()` or `context.read<AuthProvider>()`:
```dart
final auth = context.watch<AuthProvider>();

AppUser? user = auth.currentUser;
String? uid = auth.currentUid;
bool isReader = auth.isReader;
bool isAuthor = auth.isAuthor;
bool isAdmin = auth.isAdmin;

// Actions:
await context.read<AuthProvider>().becomeAuthor();
await context.read<AuthProvider>().updateProfile(
  fullName: 'New Name',
  bio: 'My bio',
  avatarUrl: 'https://...',
);
await context.read<AuthProvider>().logout();
```

### B. Public Novels Discovery & Search (`NovelProvider`)
Access via `context.watch<NovelProvider>()`:
```dart
final novelProvider = context.watch<NovelProvider>();

// Data getters:
List<Novel> novels = novelProvider.visibleNovels; // Automatically filtered & sorted
bool isLoading = novelProvider.loading;
String? error = novelProvider.error;

// Search, Filter & Sort Setters:
novelProvider.setSearchQuery('starlight');
novelProvider.setSelectedGenre('Sci-Fi'); // null to clear
novelProvider.setSelectedStatus(NovelStatus.ongoing); // null to clear
novelProvider.setSelectedSort(NovelSort.mostPopular); // recentlyUpdated, mostPopular, mostFollowed, titleAZ
novelProvider.resetFilters();

// Detail & View Counting:
Novel? novel = await novelProvider.getNovelById(novelId);
await novelProvider.recordView(novelId);
```

### C. Library, Follows & Bookmarks (`LibraryProvider`)
Access via `context.watch<LibraryProvider>()`:
```dart
final library = context.watch<LibraryProvider>();

// State:
Set<String> followedIds = library.followedNovelIds;
List<Bookmark> bookmarks = library.bookmarks;
List<ReadingProgress> history = library.readingHistory;

// Follow status check & toggle:
bool following = library.isFollowing(novelId);
await context.read<LibraryProvider>().toggleFollow(currentUserId, novelId);

// Bookmark check & toggle:
bool bookmarked = library.isBookmarked(novelId, chapterId);
await context.read<LibraryProvider>().toggleBookmark(bookmark);
```

### D. Reading Screen & Preferences (`ReadingProvider`)
Access via `context.watch<ReadingProvider>()`:
```dart
final reading = context.watch<ReadingProvider>();

// Load chapter session:
await reading.loadChapter(
  novelId: novelId,
  chapterId: chapterId,
  userId: currentUserId,
  novel: novel,
);

// Active Chapter Data:
Chapter? chapter = reading.currentChapter;
List<Chapter> publishedChapters = reading.publishedChapters;
bool hasPrev = reading.hasPreviousChapter;
bool hasNext = reading.hasNextChapter;

// Chapter Navigation:
await reading.goToPreviousChapter(userId: uid, novel: novel);
await reading.goToNextChapter(userId: uid, novel: novel);

// Reading Preferences (Auto-persisted in SharedPreferences):
double fontSize = reading.fontSize; // Default 16.0
double lineSpacing = reading.lineSpacing; // Default 1.5
String theme = reading.readingTheme; // 'light', 'dark', 'sepia'

await reading.setFontSize(18.0);
await reading.setLineSpacing(1.8);
await reading.setReadingTheme('sepia');
```

### E. Comments & Reporting (`SocialProvider`)
```dart
final social = context.watch<SocialProvider>();

await social.loadComments(chapterId);
List<ChapterComment> comments = social.comments;

await social.addComment(
  userId: uid,
  userName: user.fullName,
  novelId: novelId,
  chapterId: chapterId,
  content: 'Loved this chapter!',
);

await social.submitReport(
  reporterId: uid,
  targetType: 'chapter', // 'novel', 'chapter', 'comment'
  targetId: chapterId,
  reason: 'Inappropriate content',
  description: 'Optional details',
);
```

---

## 2. Contracts for Member 3 (Author & Admin UI)

### A. Author Studio (`AuthorProvider`)
Access via `context.watch<AuthorProvider>()`:
```dart
final author = context.watch<AuthorProvider>();

// Load author's novels:
await author.loadMyNovels(authorId);
List<Novel> myNovels = author.myNovels;

// Create Novel:
String novelId = await author.createNovel(
  authorId: currentUserId,
  authorName: currentUser.fullName,
  title: 'My Epic Sagas',
  description: 'A grand adventure...',
  genres: ['Fantasy', 'Adventure'],
  coverUrl: 'https://...',
  status: NovelStatus.ongoing,
);

// Update / Archive / Publish:
await author.updateNovel(novel);
await author.archiveNovel(novelId, authorId); // Soft-archive (visibility = hidden)
await author.publishNovel(novelId, authorId); // Requires >= 1 published chapter

// Chapter Management:
await author.loadChapters(novelId);
List<Chapter> chapters = author.getChaptersForNovel(novelId);

String chapterId = await author.createChapter(
  novelId: novelId,
  authorId: authorId,
  title: 'Chapter 1: The Beginning',
  chapterNumber: 1, // Must be positive & unique in novel
  content: 'Chapter narrative text...',
);

await author.updateChapter(chapter);
await author.publishChapter(novelId, chapterId);
await author.unpublishChapter(novelId, chapterId);
await author.deleteDraftChapter(novelId, chapterId);
```

### B. Admin Control Center (`AdminProvider`)
Access via `context.watch<AdminProvider>()`:
```dart
final admin = context.watch<AdminProvider>();

// Dashboard Metrics:
await admin.loadDashboardMetrics();
AdminDashboardMetrics m = admin.metrics;
// m.totalUsers, m.totalAuthors, m.totalNovels, m.publishedNovels, m.pendingReports, m.totalComments

// User Moderation:
await admin.loadUsers();
List<AppUser> users = admin.users;
await admin.setUserActive(uid: targetUid, isActive: false); // Disable / suspend account

// Novel Moderation:
await admin.loadAllNovels();
List<Novel> allNovels = admin.novels;
await admin.hideNovel(novelId);
await admin.restoreNovel(novelId);

// Content Reports Triage:
await admin.loadReports();
List<ContentReport> reports = admin.reports;
await admin.resolveReport(reportId: rId, adminId: currentAdminUid);
await admin.dismissReport(reportId: rId, adminId: currentAdminUid);

// Genre Management:
await admin.loadGenres();
List<Genre> genres = admin.genres;
await admin.addGenre('Cyberpunk');
await admin.renameGenre(id: gId, newName: 'Solarpunk');
await admin.setGenreActive(id: gId, isActive: false);
```

---

## 3. Centralized Route Table

| Path | Screen Description | Owner Branch |
| :--- | :--- | :--- |
| `/login` | Sign In Screen | Core (`feature/core-integration`) |
| `/register` | Sign Up Screen | Core (`feature/core-integration`) |
| `/account-disabled` | Account Suspended Screen | Core (`feature/core-integration`) |
| `/home` | Reader Home Screen | `feature/reader-ui` |
| `/discover` | Browse & Filter Novels | `feature/reader-ui` |
| `/library` | User Reading Library | `feature/reader-ui` |
| `/profile` | Reader Profile Screen | `feature/reader-ui` |
| `/novel/:id` | Novel Overview & Chapters | `feature/reader-ui` |
| `/novel/:id/chapter/:chapterId` | Reading Screen | `feature/reader-ui` |
| `/bookmarks` | Saved Bookmarks | `feature/reader-ui` |
| `/history` | Reading History | `feature/reader-ui` |
| `/author` | Author Studio Dashboard | `feature/author-admin-ui` |
| `/author/novels` | Author Novels Management | `feature/author-admin-ui` |
| `/author/novel/new` | Create Novel Form | `feature/author-admin-ui` |
| `/author/novel/:id` | Edit Novel Form | `feature/author-admin-ui` |
| `/author/novel/:id/chapters` | Chapter Management | `feature/author-admin-ui` |
| `/author/novel/:id/chapter/new` | Create Chapter Form | `feature/author-admin-ui` |
| `/admin` | Admin Control Center | `feature/author-admin-ui` |
| `/admin/users` | User Account Moderation | `feature/author-admin-ui` |
| `/admin/novels` | Novel Content Moderation | `feature/author-admin-ui` |
| `/admin/reports` | Content Reports Review | `feature/author-admin-ui` |
| `/admin/genres` | Genre Category Taxonomy | `feature/author-admin-ui` |


---

## 4. Route Navigation Helpers & Code Examples

Do **NOT** hardcode raw route strings in your widgets. Always use `AppRoutes` and the provided path generator methods:

```dart
import 'package:go_router/go_router.dart';
import 'package:inkverse/app/router.dart';

// -------------------------------------------------------------
// Reader Navigation Examples (Member 2)
// -------------------------------------------------------------

// Switch bottom navigation tabs in MainNavigationShell:
context.go(AppRoutes.home);
context.go(AppRoutes.discover);
context.go(AppRoutes.library);
context.go(AppRoutes.profile);

// Navigate to fullscreen screens (hides bottom NavigationBar):
context.push(AppRoutes.novelDetailPath(novel.id));
context.push(AppRoutes.readingPath(novel.id, chapter.id));
context.push(AppRoutes.bookmarks);
context.push(AppRoutes.history);

// -------------------------------------------------------------
// Author Navigation Examples (Member 3)
// -------------------------------------------------------------

// Access Author Dashboard:
context.push(AppRoutes.author);
context.push(AppRoutes.authorNovels);
context.push(AppRoutes.authorNovelNew);
context.push(AppRoutes.authorNovelEditPath(novel.id));
context.push(AppRoutes.authorChaptersPath(novel.id));
context.push(AppRoutes.authorChapterNewPath(novel.id));

// -------------------------------------------------------------
// Admin Navigation Examples (Member 3)
// -------------------------------------------------------------

// Access Admin Console:
context.push(AppRoutes.admin);
context.push(AppRoutes.adminUsers);
context.push(AppRoutes.adminNovels);
context.push(AppRoutes.adminReports);
context.push(AppRoutes.adminGenres);
```

---

## 5. Simplified Direct-to-Main Git Collaboration

To eliminate branching complexity, all team members branch from and merge directly into `main`:

```bash
# 1. Start feature work from latest main:
git checkout main
git pull origin main
git checkout -b feature/<your-feature-name>

# 2. Before submitting your Pull Request:
git fetch origin
git merge origin/main
flutter analyze
flutter test

# 3. Push and open PR targeting main:
git push origin feature/<your-feature-name>
# Open PR: feature/<your-feature-name> -> main
```
