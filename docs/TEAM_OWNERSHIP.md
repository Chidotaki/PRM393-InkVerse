# InkVerse – Team Responsibilities & Ownership Matrix

This document defines module boundaries, ownership, and branch workflow for the PRM393 group project.

---

## 1. Team Allocation

| Member | Role | Assigned Modules | Working Branch | GitHub Issue |
| :--- | :--- | :--- | :--- | :--- |
| **Lead Developer** | Architecture & Core Foundation | Models, Repositories, Providers, Services, Auth Screens, Routing, Security Rules, Firebase Integration | `feature/core-integration` | Lead Core Task |
| **Member 2** | Reader UI Developer | Reader Home, Discover, Novel Detail, Reading Screen, Library, Profile, Reader reusable widgets | `feature/reader-ui` | Issue #1 |
| **Member 3** | Author & Admin UI Developer | Author Dashboard, My Novels, Novel Form, Chapter Management, Admin Dashboard, Users, Moderation, Reports, Genres | `feature/author-admin-ui` | Issue #2 |

---

## 2. Component Ownership Boundaries

### Lead Developer (Core)
- **Directory Scope**:
  - `lib/core/`
  - `lib/models/`
  - `lib/services/`
  - `lib/repositories/`
  - `lib/providers/`
  - `lib/screens/auth/`
  - `lib/app/router.dart`
  - `lib/app/theme.dart`
  - `firestore.rules`, `firestore.indexes.json`
- **Responsibilities**:
  - Maintain compilation health and `flutter analyze` zero-issue baseline.
  - Implement and maintain Firebase & in-memory mock repositories.
  - Provide tested provider data contracts to Member 2 and Member 3.
  - Handle merging of feature branches into `develop`.

### Member 2 (Reader UI)
- **Target Screens**:
  - Reader Home (`lib/screens/reader/reader_home_screen.dart`)
  - Discover (`lib/screens/reader/discover_screen.dart`)
  - Novel Detail (`lib/screens/reader/novel_detail_screen.dart`)
  - Reading Screen (`lib/screens/reader/reading_screen.dart`)
  - Library Screen (`lib/screens/reader/library_screen.dart`)
  - Profile Screen (`lib/screens/reader/profile_screen.dart`)
- **Important**: Consume data only through `AuthProvider`, `NovelProvider`, `LibraryProvider`, `ReadingProvider`, and `SocialProvider`. Do not query Firestore directly.

### Member 3 (Author & Admin UI)
- **Target Screens**:
  - Author Dashboard & My Novels (`lib/screens/author/author_dashboard_screen.dart`)
  - Novel & Chapter Forms (`lib/screens/author/novel_form_screen.dart`, `chapter_form_screen.dart`)
  - Admin Dashboard & Metrics (`lib/screens/admin/admin_dashboard_screen.dart`)
  - User Moderation (`lib/screens/admin/user_management_screen.dart`)
  - Novel Moderation (`lib/screens/admin/novel_moderation_screen.dart`)
  - Report Review (`lib/screens/admin/report_management_screen.dart`)
  - Genre Taxonomy (`lib/screens/admin/genre_management_screen.dart`)
- **Important**: Consume operations via `AuthorProvider` and `AdminProvider`. Do not bypass provider business logic or write raw Firestore queries.

---

## 3. Collaboration Rules

1. **Do not modify Repository or Provider interfaces independently**:
   If an extra field or helper method is required, discuss with the Lead Developer so it can be added to both Firebase and Mock repository suites.
2. **Pull from `develop` regularly**:
   Keep your feature branch rebased/merged with `develop` to prevent diverged routes or dependencies.
3. **No direct commits to `main`**:
   All work merges through Pull Requests: `feature/*` -> `develop` -> `main`.
