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
- **Navigation & Routing**: `go_router` (Guards for reader, author, and admin roles)
- **Local Persistence**: `shared_preferences` (Reading font size, line spacing, light/dark/sepia theme)
- **Formatting**: `intl` (Timestamp and relative time formatting)

---

## 3. Team Structure & Ownership

| Member | Focus | Branch | Deliverables |
| :--- | :--- | :--- | :--- |
| **Lead Developer** | Architecture & Core | `feature/core-integration` | Models, Repositories, Providers, Auth Screens, Routing, Security Rules, Firebase / Mock Fallback |
| **Member 2** | Reader UI Module | `feature/reader-ui` | Reader Home, Discover, Novel Detail, Reading View, Library, Bookmarks, Profile |
| **Member 3** | Author & Admin UI | `feature/author-admin-ui` | Author Studio, Novel Form, Chapter Management, Admin Console, Moderation, Genres |

*See [`docs/TEAM_OWNERSHIP.md`](docs/TEAM_OWNERSHIP.md) and [`docs/TEAM_CONTRACTS.md`](docs/TEAM_CONTRACTS.md) for full integration details.*

---

## 4. User Roles & Business Rules

1. **Reader (Default)**:
   - Created on registration.
   - Can read published novels, follow novels, bookmark chapters, and leave comments.
   - May choose to become an Author (`Reader -> Author` transition).
2. **Author**:
   - Retains all Reader capabilities.
   - Can create draft novels, write chapters, and publish novels when at least one chapter is published.
   - Cannot self-promote to Admin.
3. **Admin**:
   - Platform overseer: User suspension, novel moderation, report triage, genre taxonomy.
   - **Admins CANNOT register through the UI**; they must be provisioned via Firebase console (see [`ADMIN_SETUP.md`](ADMIN_SETUP.md)).

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
firebase deploy --only firestore:rules,firestore:indexes
flutter run -d chrome
```

---

## 6. Architecture & Clean Code

InkVerse strictly separates concerns:
- **Presentation**: Reactive screens using `context.watch<T>()` and `context.read<T>()`.
- **Controllers (Providers)**: Business rules, validation, derived lists (`visibleNovels`), loading states.
- **Repository Abstraction**: Polymorphic contracts allowing seamless switching between `FirebaseUserRepository` and `MockUserRepository`.
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
*Current test suite status: 19/19 tests passing, 0 analyzer issues found.*

---

## 8. Git Strategy & Merging

- `main`: Production release branch.
- `develop`: Integration branch.
- `feature/core-integration`: Core architecture & foundation (Lead).
- `feature/reader-ui`: Reader user interface (Member 2).
- `feature/author-admin-ui`: Author and Admin user interfaces (Member 3).
