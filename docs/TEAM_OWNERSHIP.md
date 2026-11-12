# InkVerse – Architecture, Modules & Team Deliverables

This document defines module boundaries, architecture, and completed project deliverables for the PRM393 group project.

---

## 1. System Modules & Status Overview

| Module | Scope / Key Screens | Status | Deliverables |
| :--- | :--- | :--- | :--- |
| **Core Architecture** | Models, 7 Repositories, 7 Providers, Auth Gate, Navigation Shell, Theme, Security Rules | **Complete** | Production Firestore & Mock suites, robust business rule validations |
| **Reader Experience** | Reader Home, Discover, Novel Detail, Reading Screen, Library, Bookmarks, History, Profile | **Complete** | Full reading settings, chapter navigation, progress tracking, follow & comment integration |
| **Author Studio** | Author Dashboard, My Novels, Novel Form, Chapter Management, Chapter Form | **Complete** | Serial authoring, chapter sequencing, drafting, publishing, archiving |
| **Admin Console** | Admin Dashboard, User Management, Novel Moderation, Content Reports, Genre Taxonomy | **Complete** | Platform metrics, user state toggling, content moderation, report resolution, taxonomy curation |
| **Backend Integration** | Firebase Authentication, Cloud Firestore, Firebase Dev Seeder | **Complete** | Idempotent dev seeding, secure security rules, web & android configuration |

---

## 2. Component Deliverables

### Core Foundation
- **Directory Scope**:
  - `lib/core/` (Constants, errors, utilities)
  - `lib/models/` (AppUser, Novel, Chapter, Bookmark, Follow, ReadingProgress, Comment, Report, Genre)
  - `lib/services/` (AuthService with Firebase & Mock implementations)
  - `lib/repositories/` (Firebase and Mock implementations for all 7 domain areas)
  - `lib/providers/` (AuthProvider, NovelProvider, LibraryProvider, ReadingProvider, AuthorProvider, AdminProvider, SocialProvider)
  - `lib/app/` (InkVerseApp, MainNavigationShell, router, theme)
  - `firestore.rules`, `firestore.indexes.json`

### Reader Experience
- **Screens**:
  - Reader Home (`lib/screens/reader/reader_home_screen.dart`)
  - Discover (`lib/screens/reader/discover_screen.dart`)
  - Novel Detail (`lib/screens/reader/novel_detail_screen.dart`)
  - Reading Screen (`lib/screens/reader/reading_screen.dart`)
  - Library Screen (`lib/screens/reader/library_screen.dart`)
  - Profile Screen (`lib/screens/reader/profile_screen.dart`)
- **Key Capabilities**:
  - Direct repository integration through root `Provider<ChapterRepository>`.
  - Comprehensive error handling with user-friendly retry states (no technical stack traces).
  - Customizable typography and reading themes (light, dark, sepia).

### Author Studio
- **Screens**:
  - Author Dashboard (`lib/screens/author/author_dashboard_screen.dart`)
  - My Novels (`lib/screens/author/my_novels_screen.dart`)
  - Novel Form (`lib/screens/author/novel_form_screen.dart`)
  - Chapter Management (`lib/screens/author/chapter_management_screen.dart`)
  - Chapter Form (`lib/screens/author/chapter_form_screen.dart`)
- **Key Capabilities**:
  - Create and edit serial novels with genre multi-selection and status tracking.
  - Write multi-chapter serials with live word count calculation.
  - Safe publishing workflow requiring at least one published chapter.
  - Draft management and safe archiving without hard-deleting records.

### Admin Console
- **Screens**:
  - Admin Dashboard (`lib/screens/admin/admin_dashboard_screen.dart`)
  - User Management (`lib/screens/admin/user_management_screen.dart`)
  - Novel Moderation (`lib/screens/admin/novel_moderation_screen.dart`)
  - Content Reports (`lib/screens/admin/report_management_screen.dart`)
  - Genre Taxonomy (`lib/screens/admin/genre_management_screen.dart`)
- **Key Capabilities**:
  - Real-time overview of users, authors, published novels, pending reports, and comments.
  - Account moderation with self-disable protection.
  - Content hiding and restoring for policy enforcement.
  - Full report resolution and dismissal workflow.
  - Genre taxonomy creation, renaming, and activation toggling.

---

## 3. Direct Git Workflow

All feature development merges directly into `main` after automated verification:

```text
feature/final-author-admin-integration ─────PR────► main
```

### Verification Standard:
- `dart format lib test` produces 0 changes.
- `flutter analyze` produces 0 issues.
- `flutter test` executes with 100% pass rate.
- `flutter build web` succeeds in both mock and Firebase modes.
