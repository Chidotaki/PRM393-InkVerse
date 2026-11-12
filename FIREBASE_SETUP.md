# InkVerse – Firebase Configuration & Deployment Guide

This guide details the exact steps for setting up Google Firebase for **InkVerse (Serial Novel Platform)**.

---

## 1. Prerequisites

- A Google Account.
- [Node.js](https://nodejs.org/) installed (for Firebase CLI).
- [Flutter SDK](https://docs.flutter.dev/) installed.

---

## 2. Firebase Console Setup

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name it: `prm393-inkverse` (or your chosen project ID).
3. (Optional) Disable Google Analytics to keep setup minimal.
4. Click **Create project**.

---

## 3. Enable Authentication

1. In the Firebase Console left menu, navigate to **Build > Authentication**.
2. Click **Get started**.
3. Under the **Sign-in method** tab:
   - Select **Email/Password**.
   - Enable the toggle for **Email/Password**.
   - Click **Save**.

---

## 4. Create Cloud Firestore Database

1. In the Firebase Console left menu, navigate to **Build > Firestore Database**.
2. Click **Create database**.
3. Select database location (e.g., `asia-southeast1` for Vietnam/Singapore).
4. Start in **Production mode** (security rules will be deployed from the repository).
5. Click **Enable**.

---

## 5. Configure FlutterFire CLI

From your terminal at the root of the repository (`PRM393-InkVerse/`):

1. Install the Firebase CLI (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. Log in to Firebase:
   ```bash
   firebase login
   ```

3. Activate the FlutterFire CLI globally:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. Configure your platforms (Android, iOS, Web, Windows):
   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```
   *This command automatically registers your application, generates `lib/firebase_options.dart`, and places `google-services.json` in `android/app/`.*

---

## 6. Deploy Firestore Security Rules & Indexes

1. Deploy the tested security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

2. Deploy query indexes:
   ```bash
   firebase deploy --only firestore:indexes
   ```

---

## 7. Development Fallback (Offline / Without Credentials)

If Firebase credentials are not yet provisioned, you can still develop and test the entire application using the built-in in-memory repository suite:

```bash
flutter run -d chrome --dart-define=USE_MOCK_BACKEND=true
```

Or enable demo seed data when connecting to a fresh Firestore database:

```bash
flutter run -d chrome --dart-define=ENABLE_DEV_SEED=true
```
