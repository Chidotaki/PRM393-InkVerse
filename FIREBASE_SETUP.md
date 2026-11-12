# InkVerse – Firebase Configuration & Deployment Guide

## Setup Status Summary

| Component | Status | Details |
| :--- | :--- | :--- |
| **Firebase Source Integration** | **COMPLETE** | Auth service, Repositories, Providers, and Error handlers fully implemented |
| **Local Tooling** | **INSTALLED** | `firebase-tools` (v15.36.0) & `flutterfire_cli` (v1.5.0) ready on workstation |
| **Firestore Security Rules** | **READY** | Configured in `firestore.rules` (Role boundaries & ownership secured) |
| **Firestore Query Indexes** | **READY** | Configured in `firestore.indexes.json` |
| **Cloud Authentication** | **MANUAL STEP REQUIRED** | Requires interactive browser authentication (`firebase login`) |
| **FlutterFire Configuration** | **PENDING LOGIN** | Blocked on interactive login to run `flutterfire configure` |
| **Dev Mock Backend Fallback** | **ACTIVE & TESTED** | `flutter run -d chrome --dart-define=USE_MOCK_BACKEND=true` (27/27 tests pass) |

---

## 1. Understanding Setup Roles & Boundaries

To prevent confusion between what is already committed in the repository and what requires developer interaction:

### Already Configured in the Repository:
1. **Full Firebase Data Layer**: `FirebaseAuthService`, 7 Firebase repositories (`FirebaseNovelRepository`, `FirebaseChapterRepository`, `FirebaseUserRepository`, `FirebaseCommentRepository`, `FirebaseBookmarkRepository`, `FirebaseReadingHistoryRepository`, `FirebaseReportRepository`), and fallback providers.
2. **Firestore Security Rules**: Hardened in `firestore.rules` preventing unauthorized role escalation, illegal writes to other authors' drafts, or tampered report states.
3. **Firestore Composite Indexes**: Configured in `firestore.indexes.json` for all compound queries.
4. **Firebase Configuration Manifest**: Root `firebase.json` mapped to `firestore.rules` and `firestore.indexes.json`.
5. **Instant Mock Fallback**: In-memory repository implementations allowing zero-configuration local runs and automated tests (`--dart-define=USE_MOCK_BACKEND=true`).
6. **Graceful Startup Screen**: `FirebaseUnconfiguredScreen` catching unconfigured native/web options and guiding developers.

### What Requires One-Time Developer Action (Interactive Browser Login):
- Google and Firebase CLI require browser-based OAuth authorization (`firebase login`). Because automated CI agents and headless environments cannot interact with browser OAuth flows without provisioned tokens, this must be executed by a human developer on their local machine.

---

## 2. Instructions for a New Developer After Cloning

If you have just cloned the repository, choose either **Path A (Instant Mock)** or **Path B (Production Cloud)**.

### Path A: Run Immediately with Mock Backend (No Setup Required)
```bash
flutter pub get
flutter run -d chrome --dart-define=USE_MOCK_BACKEND=true
```
- Completely offline, self-contained, and pre-seeded with test novels, chapters, authors, and reader accounts.

---

### Path B: Connect to Real Production Firebase

#### Step 1: Install & Verify CLI Tools
The tools are typically already globally installed. If not:
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```
Verify:
```bash
firebase --version
flutterfire --version
```

#### Step 2: One-Time Developer Interactive Login
Log into your Google account associated with your Firebase project:
```bash
firebase login
```
*(A browser window will open asking you to authenticate with Google. Grant permissions and return to the terminal.)*

#### Step 3: Configure FlutterFire for InkVerse
Run the FlutterFire CLI generator to link your Firebase project and generate `lib/firebase_options.dart`:
```bash
flutterfire configure --project=<your-firebase-project-id>
```
Select the platforms you want to build for (`android`, `ios`, `web`, `macos`, `windows`).
This command will:
- Automatically generate `lib/firebase_options.dart`.
- Download and place `google-services.json` into `android/app/`.
- Download and place `GoogleService-Info.plist` into `ios/Runner/`.

> **Security Note**: Never commit `google-services.json` or `GoogleService-Info.plist` if they contain sensitive production secrets. `lib/firebase_options.dart` is gitignored by default for custom developer deployments.

#### Step 4: Deploy Firestore Rules and Indexes
From the repository root:
```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

#### Step 5: Enable Firebase Authentication
In the [Firebase Console](https://console.firebase.google.com/):
1. Navigate to **Build > Authentication** > **Sign-in method**.
2. Enable the **Email/Password** provider and save.

#### Step 6: Run Against Real Firebase
```bash
# Optional: Seed initial demo catalog into fresh Firestore instance
flutter run -d chrome --dart-define=ENABLE_DEV_SEED=true

# Standard run
flutter run -d chrome
```
