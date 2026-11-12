# InkVerse – Cloud Firestore Security Specification & Invariants

This document details the security rules, role model, and access control invariants implemented in `firestore.rules`.

---

## 1. Role Model Hierarchy

```text
       ┌───────────┐
       │   Admin   │  (Platform Management & Moderation)
       └─────┬─────┘
             │ Inherits all Author & Reader capabilities
       ┌─────▼─────┐
       │  Author   │  (Novel & Chapter Publishing)
       └─────┬─────┘
             │ Inherits all Reader capabilities
       ┌─────▼─────┐
       │  Reader   │  (Reading, Library, Comments, Reports)
       └───────────┘
```

- **Reader (Default)**: Automatically assigned upon registration. Can read published novels, manage personal library, post comments, and submit content violation reports.
- **Author**: Can transition from `reader` ➔ `author` via self-service action (`becomeAuthor()`). Authors can create, edit, publish, and archive their own novels and chapters.
- **Admin**: Oversees platform operations, user suspension, novel moderation, report triage, and genre taxonomy. **Admins cannot be created via the client app; they must be provisioned through trusted administrative channels** (see [`ADMIN_SETUP.md`](../ADMIN_SETUP.md)).

---

## 2. Access Control Invariants by Collection

### A. Users (`/users/{userId}`)
- **Read**: Any signed-in user can read profiles (needed for author display names and comment attribution).
- **Create**:
  - Must match authenticated `request.auth.uid == userId`.
  - Initial `role` MUST strictly be `'reader'`.
  - `isActive` MUST strictly be `true`.
- **Update**:
  - **Self-Service Promotion**: An authenticated user may transition from `role: 'reader'` to `role: 'author'`.
  - **Admin Privilege Violation Guard**: Users CANNOT promote themselves or others to `'admin'`.
  - **Profile Updates**: Users can update `fullName`, `bio`, and `avatarUrl`, but cannot change their `email`, `uid`, or `isActive` status.
  - **Admin Overrides**: Administrators can update all user documents, including setting `isActive: false` (account suspension).
- **Delete**: Restricted exclusively to platform administrators.

### B. Novels (`/novels/{novelId}`)
- **Read**:
  - Published novels (`visibility == 'published'`) can be read by any signed-in user.
  - Drafts and hidden novels are strictly restricted to the author owner (`authorId == request.auth.uid`) or platform admins.
- **Create**:
  - Only authorized authors (`role == 'author' || role == 'admin'`).
  - Document `authorId` MUST match authenticated user.
  - New novels must start with `visibility == 'draft'`.
- **Update**:
  - Only the owning author (`resource.data.authorId == request.auth.uid`) or admin.
  - Authors cannot reassign novel ownership (`request.resource.data.authorId == resource.data.authorId`).
  - Atomic counter updates (`viewCount`, `followerCount`, `chapterCount`) are allowed via authorized transaction paths.
- **Delete**: Restricted exclusively to platform administrators.

### C. Chapters (`/chapters/{chapterId}`)
- **Read**:
  - Published chapters (`status == 'published'`) readable by any signed-in user.
  - Draft chapters restricted to the author owner or platform admin.
- **Create**:
  - Restricted to authors with `authorId == request.auth.uid`.
- **Update**:
  - Restricted to author owner or admin. Ownership cannot be reassigned.
- **Delete**:
  - Authors can only delete draft chapters. Published chapters can only be removed/moderated by platform admins.

### D. Library Collections (Follows, Bookmarks, Reading Progress)
- **Follows (`/follows/{followId}`)**:
  - Deterministic document key: `{userId}_{novelId}`.
  - Creation, reading, and deletion restricted to the record owner (`userId == request.auth.uid`) or admin.
- **Bookmarks (`/bookmarks/{bookmarkId}`)**:
  - Deterministic document key: `{userId}_{novelId}_{chapterId}`.
  - Creation, reading, updates, and deletion restricted to the record owner (`userId == request.auth.uid`).
- **Reading Progress (`/reading_progress/{progressId}`)**:
  - Deterministic document key: `{userId}_{novelId}`. Exactly one record per user and novel.
  - Upsert (create/update) and reading restricted to the record owner (`userId == request.auth.uid`).

### E. Comments (`/comments/{commentId}`)
- **Read**: Any signed-in user.
- **Create**: Authenticated user matching `userId == request.auth.uid` with non-empty content and `isDeleted == false`.
- **Update**:
  - Normal users can only edit their own comments.
  - Administrators can moderate comments.
- **Delete**: Restricted to administrators.

### F. Reports (`/reports/{reportId}`)
- **Create**: Any signed-in user can submit a report with `reporterId == request.auth.uid` and `status == 'pending'`.
- **Read, Update, Delete**: Restricted strictly to platform administrators (`isAdmin()`). Readers and authors cannot view or resolve reports.

### G. Genres (`/genres/{genreId}`)
- **Read**: Any signed-in user.
- **Create, Update, Delete**: Restricted strictly to platform administrators.

---

## 3. Negative Security Verification Matrix

| Attempted Action | Actor | Expected Outcome | Security Rule Guard |
| :--- | :--- | :--- | :--- |
| Self-promote to Admin (`role = 'admin'`) | Reader / Author | **REJECTED (Permission Denied)** | `users/{userId}` update rule validates only `reader -> author` transition |
| Modify another user's profile | Reader | **REJECTED** | `isOwner(userId)` requires `request.auth.uid == userId` |
| Edit another author's novel | Author | **REJECTED** | `novels/{novelId}` update requires `isOwner(resource.data.authorId)` |
| Edit another author's chapter | Author | **REJECTED** | `chapters/{chapterId}` update requires `isOwner(resource.data.authorId)` |
| Access another user's bookmarks | Reader | **REJECTED** | `bookmarks/{bookmarkId}` read requires `resource.data.userId == request.auth.uid` |
| View pending moderation reports | Reader / Author | **REJECTED** | `reports/{reportId}` read restricted to `isAdmin()` |
| Resolve or dismiss a report | Reader / Author | **REJECTED** | `reports/{reportId}` update restricted to `isAdmin()` |
| Create or delete a genre | Reader / Author | **REJECTED** | `genres/{genreId}` write restricted to `isAdmin()` |
| Read hidden / draft novel of another author | Reader | **REJECTED** | `novels/{novelId}` read restricts unpublished works to owner and admin |
