# InkVerse – Serial Novel Platform

**PRM393 Group Project** • University Course Project  
**Repository**: [Chidotaki/PRM393-InkVerse](https://github.com/Chidotaki/PRM393-InkVerse)  
**Package**: `inkverse` (`com.prm393.inkverse`)  
**Production Firebase**: `inkverse-prm393-812005`  

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
- **CI / Automation**: GitHub Actions (`.github/workflows/flutter-ci.yml`)

---

## 3. Product Architecture & Modules

| Module | Status | Screens Included |
| :--- | :--- | :--- |
| **Core Architecture** | **Complete** | Models, 7 Repositories, 7 Providers, Navigation Shell, Theme, Security Rules |
| **Reader UI** | **Complete** | Home, Discover, Novel Detail, Reading Screen, Library, Bookmarks, Profile |
| **Author Studio** | **Complete** | Author Dashboard, My Novels, Novel Form, Chapter Management, Chapter Form |
| **Admin Console** | **Complete** | Admin Dashboard, User Management, Novel Moderation, Content Reports, Genre Taxonomy |
| **Backend Integration** | **Complete** | Cloud Firebase (`inkverse-prm393-812005`) & In-Memory Mock Backend |

*See [`docs/TEAM_OWNERSHIP.md`](docs/TEAM_OWNERSHIP.md) and [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) for full architecture details.*

---

## 4. Getting Started & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/) (>= 3.13.2)
- Google Chrome or connected Android/iOS device
- Node.js (>= 20) & npm

### 1. Clone & Install Dependencies
```bash
git clone https://github.com/Chidotaki/PRM393-InkVerse.git
cd PRM393-InkVerse
flutter pub get
```

### 2. Run with In-Memory Mock Backend (Instant Dev / Offline Mode)
No Firebase credentials required! Perfect for UI prototyping, testing, CI, and grading:
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
```bash
flutter run -d chrome
```

To enable development catalog seeding in Profile (admin account required):
```bash
flutter run -d chrome --dart-define=ENABLE_DEV_SEED=true
```

---

## 5. Verification & Testing

Run the full automated test suite:
```bash
flutter test
```

Run static analysis:
```bash
dart format lib test
flutter analyze
```

Build production web bundle:
```bash
flutter build web
```
