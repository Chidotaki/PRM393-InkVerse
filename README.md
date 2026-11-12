# InkVerse – Serial Novel Platform

**PRM393 Group Project** • University Course Project  
**Repository**: [Chidotaki/PRM393-InkVerse](https://github.com/Chidotaki/PRM393-InkVerse)  
**Package**: `inkverse` (`com.prm393.inkverse`)  
**Team Size**: 3 Members  

---

## 1. Project Concept & Overview

**InkVerse** is a modern serial novel reading and publishing platform built with Flutter. It connects readers and authors through an episodic, chapter-based publishing workflow.

- **Readers** explore novels across diverse literary genres, follow works in progress, track chapter reading progress, save bookmarks, customize reader font/line spacing/themes, comment on chapters, and report policy violations.
- **Authors** write and manage multi-chapter serialized stories, save drafts, publish chapters with unique numbering validation, monitor views and followers, and publish novels when chapters are ready.
- **Administrators** monitor system metrics, suspend/reinstate users, moderate reported content, hide/restore reported novels, and manage platform genres.

---

## 2. Technology Stack

- **Framework**: Flutter 3.x / Dart 3.x (Material 3)
- **Backend Services**:
  - Firebase Authentication (Email/Password)
  - Cloud Firestore (Structured real-time NoSQL database)
- **State Management**: Provider (`ChangeNotifierProvider`, `MultiProvider`)
- **Navigation & Routing**: `go_router` (with `MainNavigationShell` and role guards)
- **Local Persistence**: `shared_preferences` (Reading font size, line spacing, light/dark/sepia theme)
- **Formatting**: `intl` (Timestamp and relative time formatting)

---

## 3. Team Structure & Ownership

| Member | Focus | Branch | Deliverables |
| :--- | :--- | :--- | :--- |
| **Lead Developer** | Architecture & Core | `feature/core-integration` | Models, Repositories, Providers, Auth Screens, Shell & Routing, Security Rules, Firebase / Mock Fallback |
| **Member 2** | Reader UI Module | `feature/reader-ui` | Reader Home, Discover, Novel Detail, Reading View, Library, Bookmarks, Profile |
| **Member 3** | Author & Admin UI | `feature/author-admin-ui` | Author Studio, Novel Form, Chapter Management, Admin Console, Moderation, Genres |

*See [`docs/TEAM_OWNERSHIP.md`](docs/TEAM_OWNERSHIP.md) and [`docs/TEAM_CONTRACTS.md`](docs/TEAM_CONTRACTS.md) for full integration details.*

---

## 4. Current Project Status

| Area | Status | Notes |
| :--- | :--- | :--- |
| **Core Architecture** | **Complete** | Models, 7 Repositories, 7 Providers, Material 3 App & Theme |
| **Navigation Shell** | **Complete** | `MainNavigationShell` with bottom navigation & role badges |
| **Mock Backend** | **Complete** | 8+ novels, 3 authors, chapters, comments, reports, 4 test accounts |
| **Firebase Source Integration** | **Complete** | Full Firestore / Auth implementation & security rules |
| **Firebase Runtime Setup** | **External Configuration Required** | Awaiting `flutterfire configure` with live Firebase project |
| **Reader UI** | **Assigned** | Owned by Member 2 ([Issue #1](https://github.com/Chidotaki/PRM393-InkVerse/issues/1)) |
| **Author & Admin UI** | **Assigned** | Owned by Member 3 ([Issue #2](https://github.com/Chidotaki/PRM393-InkVerse/issues/2)) |
| **Final Integration** | **Pending UI branches** | Shell & placeholders ready for direct screen replacement |

*See [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) for the detailed verification and integration checklist.*

---

## 5. Getting Started & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/) (>= 3.13.2)
- Google Chrome or connected Android/iOS device

### 1. Clone & Install Dependencies
```bash
git clone https://github.com/Chidotaki/PRM393-InkVerse.git
cd PRM393-InkVerse
flutter pub get
```

### 2. Run with In-Memory Mock Backend (Instant Dev / Offline Mode)
No Firebase credentials required! Perfect for UI prototyping, testing, and grading:
```bash
flutter run -d chrome --dart-define=USE_MOCK_BACKEND=true
```

**Pre-configured Mock Accounts:**
| Role | Email | Password |
| :--- | :--- | :--- |
| **Reader** | `reader@inkverse.com` | `password123` |
| **Author** | `author@inkverse.com` | `password123` |
| **Admin** | `admin@inkverse.com` | `password123` |
| **Disabled** | `disabled@inkverse.com` | `password123` |

### 3. Run with Cloud Firebase (Production Mode)
Follow the step-by-step setup in [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md):
```bash
flutterfire configure
firebase deploy --only firestore
flutter run -d chrome
```

---

## 6. Architecture & Clean Code

InkVerse strictly separates concerns:
- **Presentation**: `MainNavigationShell` with bottom bar + fullscreen routes, reactive screens using `context.watch<T>()`.
- **Controllers (Providers)**: Business rules, validation, derived lists (`visibleNovels`), loading states.
- **Repository Abstraction**: Polymorphic contracts allowing seamless switching between `Firebase*Repository` and `Mock*Repository`.
- **Infrastructure**: Firebase Auth, Cloud Firestore, SharedPreferences.

For in-depth architecture details, consult [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## 7. Quality Assurance & Verification

Format, analyze, and run test suites:
```bash
dart format lib test
flutter analyze
flutter test
```

---

## 8. Simplified Direct-to-Main Git Workflow

All members branch from `main` and submit Pull Requests directly into `main`:

```text
feature/core-integration   ──► Pull Request ──► main
feature/reader-ui          ──► Pull Request ──► main
feature/author-admin-ui    ──► Pull Request ──► main
```

### Standard Feature Flow:
```bash
# 1. Start from latest main
git checkout main
git pull origin main
git checkout -b feature/<your-feature-name>

# 2. Before creating PR, pull latest main changes and test
git fetch origin
git merge origin/main
flutter analyze
flutter test

# 3. Push and open PR targeting main
git push origin feature/<your-feature-name>
```
