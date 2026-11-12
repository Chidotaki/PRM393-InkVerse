# InkVerse – Live Demonstration & Presentation Script

This guide outlines a seamless end-to-end demonstration flow for university grading and course presentations using the in-memory mock suite (`--dart-define=USE_MOCK_BACKEND=true`).

---

## 1. Launching the Demo

Launch the application directly in Google Chrome:
```bash
flutter run -d chrome --dart-define=USE_MOCK_BACKEND=true
```

---

## 2. Walkthrough Steps

### Act 1: Reader Experience
1. **Sign In**:
   - Email: `reader@inkverse.com`
   - Password: `password123`
   - Role automatically recognized as **Reader**.
2. **Main Navigation Shell**:
   - Observe Material 3 persistent bottom navigation with 4 tabs: **Home**, **Discover**, **Library**, **Profile**.
3. **Discover Novels**:
   - Tap **Discover** in the bottom navigation.
   - Filter by genre (e.g., *Sci-Fi*, *Fantasy*) and search for novels (e.g., `"The Last Starfarer"`).
   - *(Screen status: Integrated via `DiscoverPlaceholderScreen`, awaiting Member 2 UI merge)*.
4. **Open Novel Details**:
   - Tap `"The Last Starfarer"` to view details.
   - Bottom navigation smoothly hides as novel details open full-screen.
5. **Follow Novel & Read Chapter**:
   - Tap **Follow** (increments follower count safely and idempotently).
   - Tap **Read Chapter 1** to open the reading screen.
   - Demonstrate bookmarking (`addBookmark`) and reading progress tracking (`saveReadingProgress`).
   - Tap **Back to Novel** and return to Reader Shell.
6. **Library Check**:
   - Switch to **Library** tab in bottom navigation.
   - Confirm novel is listed under followed novels, bookmarks, and reading history.

---

### Act 2: Reader ➔ Author Promotion & Publishing
1. **Navigate to Profile**:
   - Switch to **Profile** tab in the bottom navigation.
   - Observe current role badge: `Role: READER`.
2. **Become an Author**:
   - Tap **Become an Author**.
   - Watch role badge dynamically transition to `Role: AUTHOR`.
   - Notice the persistent navigation shell immediately surfaces the **Author Studio** banner shortcut.
3. **Open Author Studio**:
   - Tap **Author Studio** in the banner or navigate to `/author`.
   - *(Screen status: Integrated via `AuthorDashboardPlaceholderScreen`, awaiting Member 3 UI merge)*.
4. **Create & Publish Workflow**:
   - Tap **Create Novel** ➔ Created in `draft` status.
   - Add **Chapter 1** ➔ Created in `draft` status.
   - Try publishing novel before publishing chapter ➔ Invariant prevents publication until at least one chapter is published.
   - Publish Chapter 1 ➔ Status changes to `published`.
   - Publish Novel ➔ Visibility changes to `published`.
5. **Verify Public Visibility**:
   - Return to Reader Shell (`/home` or `/discover`).
   - Confirm newly published novel is now immediately visible to all readers.

---

### Act 3: Administrator Moderation
1. **Sign Out & Sign In as Admin**:
   - Sign out via Profile or AppBar.
   - Sign in as `admin@inkverse.com` / `password123`.
2. **Admin Entry**:
   - The app detects admin credentials and opens the **Admin Control Center** (`/admin`).
   - Notice that readers cannot access this route (route guard automatically redirects unauthorized users to `/home`).
3. **User Moderation**:
   - Navigate to `/admin/users`.
   - Suspend a user account (`isActive = false`).
   - Attempting to disable the current admin account is strictly blocked by `AdminProvider`.
4. **Novel & Content Moderation**:
   - Navigate to `/admin/novels` ➔ Hide reported novel.
   - Navigate to `/admin/reports` ➔ Review and resolve content violation reports.
   - Navigate to `/admin/genres` ➔ Add new genre category (demonstrates case-insensitive duplicate prevention).

---

## 3. Teammate Module Status Summary for Demo Evaluators

| Module | Scope | Ownership | Status in Demo |
| :--- | :--- | :--- | :--- |
| **Core Architecture & Backend** | Models, Providers, Repositories, Navigation Shell, Auth | **Lead Developer** | **Fully Operational** |
| **Reader UI Module** | Home, Discover, Detail, Reading, Library, Profile | **Member 2** | Scaffolded via Clean Integration Placeholders (Issue #1) |
| **Author & Admin UI Module** | Dashboard, Novel/Chapter Forms, Moderation, Genres | **Member 3** | Scaffolded via Clean Integration Placeholders (Issue #2) |
