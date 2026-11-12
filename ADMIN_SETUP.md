# InkVerse – Admin Account Provisioning Guide

## Security Principle
In InkVerse, **users can NEVER self-promote to the `admin` role through the client UI or public APIs**.
The Firestore security rules explicitly forbid creating or modifying documents where `role == 'admin'` from untrusted clients.

---

## Classroom Bootstrap (Academic / University Demo)

To provision the first platform administrator for demonstration and grading purposes:

1. **Launch the application** (web or mobile):
   ```bash
   flutter run -d chrome
   ```
2. **Register a regular account** via the Register screen:
   - Full Name: `Admin User`
   - Email: `admin@prm393.edu` (or any valid email)
   - Password: `password123`
3. **Open the Firebase Console**:
   - Navigate to **Firestore Database** > `users` collection.
   - Locate the document whose `email` matches `admin@prm393.edu`.
4. **Edit the `role` field**:
   - Change the `role` string from `"reader"` to `"admin"`.
   - Ensure `isActive` is set to `true`.
5. **Sign out and sign in again**:
   - Log out of InkVerse.
   - Log back in with `admin@prm393.edu`.
   - The router will detect `isAdmin == true` and route you directly to the **Admin Control Center** (`/admin`).

---

## Production Provisioning (Best Practice)
In commercial production environments, admin privileges must never be granted via client interactions. They should be provisioned via:
1. **Firebase Admin SDK** (Node.js/Python microservice running on a secure server or Cloud Function).
2. **Firebase Auth Custom Claims**:
   ```javascript
   await admin.auth().setCustomUserClaims(uid, { admin: true });
   ```
3. Secure audit logging of administrator additions.
