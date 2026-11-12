# InkVerse – Team Responsibilities & Ownership Matrix

This document defines module boundaries, ownership, and branch workflow for the PRM393 group project.

---

## 1. Team Allocation

| Member | Role | Assigned Modules | Working Branch | GitHub Issue |
| :--- | :--- | :--- | :--- | :--- |
| **Lead Developer** | Architecture & Core Foundation | Models, Repositories, Providers, Services, Auth Screens, Navigation Shell, Routing, Security Rules, Firebase Integration | `feature/core-integration` | Lead Core Task |
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
  - `lib/app/shell/`
  - `lib/app/router.dart`
  - `lib/app/theme.dart`
  - `firestore.rules`, `firestore.indexes.json`
- **Responsibilities**:
  - Maintain compilation health and `flutter analyze` zero-issue baseline.
  - Implement and maintain Firebase & in-memory mock repositories.
  - Provide tested provider data contracts to Member 2 and Member 3.
  - Maintain the navigation shell (`MainNavigationShell`) and router.
  - Review and handle merging of teammate feature Pull Requests into `main`.

### Member 2 (Reader UI)
- **Target Screens**:
  - Reader Home (`lib/screens/reader/reader_home_screen.dart`)
  - Discover (`lib/screens/reader/discover_screen.dart`)
  - Novel Detail (`lib/screens/reader/novel_detail_screen.dart`)
  - Reading Screen (`lib/screens/reader/reading_screen.dart`)
  - Library Screen (`lib/screens/reader/library_screen.dart`)
  - Profile Screen (`lib/screens/reader/profile_screen.dart`)
- **Important**: Consume data only through `AuthProvider`, `NovelProvider`, `LibraryProvider`, `ReadingProvider`, and `SocialProvider`. Do not query Firestore directly. Bottom navigation is managed by `MainNavigationShell`.

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

## 3. Simplified Direct-to-Main Git Workflow

To reduce coordination friction, the team uses a **direct-to-main feature branch** model:

```text
Lead:     feature/core-integration  ─────PR────► main
Member 2: feature/reader-ui         ─────PR────► main
Member 3: feature/author-admin-ui   ─────PR────► main
```

### Member Step-by-Step Flow:
1. **Branch from latest `main`**:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/<your-feature-name>
   ```
2. **Work and test on your feature branch**:
   ```bash
   flutter run -d chrome --dart-define=USE_MOCK_BACKEND=true
   flutter test
   ```
3. **Synchronize before creating Pull Request**:
   ```bash
   git fetch origin
   git merge origin/main
   # resolve any conflicts, verify tests pass
   flutter analyze
   flutter test
   git push origin feature/<your-feature-name>
   ```
4. **Open PR to `main`**:
   Create a Pull Request on GitHub targeting `main`. When reviewed and verified, merge into `main`.
