# InkVerse – Architecture & Design Specification

## 1. System Overview

**InkVerse** is an episodic serial novel reading and publishing platform built with **Flutter**, **Provider**, **GoRouter**, and **Firebase**.
It is architected using Clean Architecture principles tailored for an understandable, maintainable university group project.

```
┌───────────────────────────────────────────────────────────┐
│                       Presentation Layer                  │
│       Screens / Widgets / Temporary Placeholders          │
└─────────────────────────────▲─────────────────────────────┘
                              │ context.watch<T>() / context.read<T>()
┌─────────────────────────────▼─────────────────────────────┐
│                        Provider Layer                     │
│  AuthProvider, NovelProvider, LibraryProvider, ...        │
└─────────────────────────────▲─────────────────────────────┘
                              │ Repository interface calls
┌─────────────────────────────▼─────────────────────────────┐
│                       Repository Layer                    │
│   UserRepository, NovelRepository, ChapterRepository, ... │
└─────────────────────────────▲─────────────────────────────┘
                              │
             ┌────────────────┴────────────────┐
             ▼                                 ▼
   Cloud Firestore / Auth            In-Memory Mock Suite
   (Production Implementation)       (Development / Offline)
```

---

## 2. Technology Stack

- **Framework**: Flutter 3.x (Dart 3.x)
- **Design System**: Material 3 with literary styling (Deep Ink & Warm Parchment)
- **State Management**: Provider (`ChangeNotifierProvider`, `MultiProvider`)
- **Routing & Guards**: `go_router` (role-based redirects)
- **Backend**: Firebase Auth (Email/Password) & Cloud Firestore
- **Local Persistence**: `shared_preferences` (reader display preferences)
- **Formatting**: `intl` (dates, relative time)

---

## 3. Core Directory Layout

```
lib/
├── main.dart                          # App entrypoint & backend selector
│
├── app/
│   ├── app.dart                       # MultiProvider registration & MaterialApp
│   ├── router.dart                    # GoRouter configuration & guards
│   ├── theme.dart                     # Material 3 light/dark theme definitions
│   └── integration_placeholders.dart  # Minimal placeholder screens for teammates
│
├── core/
│   ├── constants/                     # Centralized collections, keys & defaults
│   ├── errors/                        # Domain AppException & error mapping
│   └── utils/                         # Safe timestamp parsing & responsive helpers
│
├── models/                            # Pure domain entities (fromMap/toMap)
│   ├── app_user.dart
│   ├── novel.dart
│   ├── chapter.dart
│   ├── follow.dart
│   ├── bookmark.dart
│   ├── reading_progress.dart
│   ├── chapter_comment.dart
│   ├── content_report.dart
│   └── genre.dart
│
├── services/                          # Auth service abstraction & Firebase implementation
│   └── auth_service.dart
│
├── repositories/                      # Abstract contracts + Firebase implementations
│   ├── user_repository.dart
│   ├── novel_repository.dart
│   ├── chapter_repository.dart
│   ├── library_repository.dart
│   ├── comment_repository.dart
│   ├── report_repository.dart
│   ├── genre_repository.dart
│   └── mock/mock_repositories.dart    # Full in-memory mock suite for offline dev
│
├── providers/                         # Reactive business logic controllers
│   ├── auth_provider.dart
│   ├── novel_provider.dart
│   ├── library_provider.dart
│   ├── reading_provider.dart
│   ├── author_provider.dart
│   ├── social_provider.dart
│   └── admin_provider.dart
│
└── screens/                           # Complete Material 3 core screens
    └── auth/
        ├── login_screen.dart
        ├── register_screen.dart
        ├── auth_gate_screen.dart
        └── account_disabled_screen.dart
```

---

## 4. Roles & Authorization Rules

| Role | Allowed Transitions | Capabilities |
| :--- | :--- | :--- |
| **Reader** | Reader -> Author | Read published novels, follow, bookmark, track progress, comment, report, update profile. |
| **Author** | None (Permanent) | All Reader capabilities + create novels, manage chapters, publish chapters/novels, view analytics. |
| **Admin** | None | User moderation (enable/disable), novel moderation (hide/restore), report triage, genre management. |

### Security Guarantees
- Users **cannot self-promote to `admin`** under any circumstance.
- Authors can **only edit/publish/archive their own novels and chapters**.
- Readers can **only modify their own bookmarks, follows, and reading progress**.
- Disabled accounts (`isActive == false`) are immediately locked out of normal routes.

---

## 5. Data Flow Pipeline

1. **User Interaction**: User taps a button or types input in a Screen.
2. **Provider Action**: The screen calls a method on the injected Provider (e.g., `context.read<LibraryProvider>().toggleFollow(...)`).
3. **Repository Execution**: The Provider executes business logic and invokes the abstract Repository interface.
4. **Backend Sync**: The concrete Repository performs a Firestore transaction or batch write.
5. **Reactive State Update**: Upon completion, the Provider updates its local state and notifies listeners (`notifyListeners()`), updating UI instantly without blocking user navigation.


---

## 6. Application Shell & Navigation Architecture

InkVerse employs a hybrid navigation structure using `go_router`:
1. **Persistent Bottom Shell (`MainNavigationShell`)**:
   Uses `StatefulShellRoute.indexedStack` to preserve state across Reader primary destinations:
   - `/home` (Reader Home)
   - `/discover` (Discover / Browse)
   - `/library` (Follows / Bookmarks / History)
   - `/profile` (User Account & Preferences)
   Also displays an active shortcut badge for Authors (`/author`) and Admins (`/admin`).
2. **Fullscreen Immersive Routes**:
   Pushed on top of the root navigator (`_rootNavigatorKey`), automatically hiding the bottom navigation bar:
   - `/novel/:id` (Novel Detail)
   - `/novel/:id/chapter/:chapterId` (Reader Screen)
   - `/author/*` (Author Dashboard, Novel & Chapter Forms)
   - `/admin/*` (Admin Dashboard, User/Novel Moderation, Reports, Genres)

---

## 7. Simplified Direct-to-Main Workflow

```text
feature/core-integration   ──► Pull Request ──► main
feature/reader-ui          ──► Pull Request ──► main
feature/author-admin-ui    ──► Pull Request ──► main
```
Each member branches from `main`, tests locally with mock or Firebase backend, merges latest `main` prior to PR, and opens a PR targeting `main`.
