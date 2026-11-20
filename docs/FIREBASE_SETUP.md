# Firebase setup (push notifications)

The app and the backend already contain all the push code (D8). It stays **off** until the
three files below exist, and nothing breaks without them:

- the app builds and runs, and notifications still appear in the in-app inbox (bell);
- the backend stores every notification and logs "Push disabled" instead of sending.

**You (the owner) do the Firebase console steps.** They need your Google account, and the
files they produce must never be committed. `.gitignore` already excludes
`google-services.json`, `GoogleService-Info.plist` and `.env`.

## Before you start: the app ID

Firebase registers the app by its **package name / bundle ID**. Today it is the placeholder
`com.example.gym_app` (OPEN_QUESTIONS #7). Decide the final ID first. If you register the
placeholder and change it later, you must register the app again and download new files.

## 1. Create the project

1. Open <https://console.firebase.google.com> and click **Add project**. Use a name such as
   "Gym App". Google Analytics is not needed.
2. Open **Project settings → Cloud Messaging** and check that the *Firebase Cloud Messaging
   API (V1)* is **Enabled**.

## 2. Android app

1. **Project settings → General → Your apps → Add app → Android**.
2. Enter the package name `com.example.gym_app`, or the final ID if you changed it in
   `mobile/android/app/build.gradle.kts` (`applicationId` and `namespace`).
3. Leave the SHA-1 empty; push does not need it.
4. Download **`google-services.json`** and copy it to `mobile/android/app/google-services.json`.
5. Rebuild the app (`flutter run ...`). The Gradle build applies the Google Services plugin
   automatically when the file is present.

## 3. iOS app (needed for D14)

1. In the Apple Developer account, open **Certificates, IDs & Profiles → Keys → +**, enable
   **Apple Push Notifications service (APNs)** and download the `.p8` key. Note its Key ID
   and your Team ID.
2. In Firebase, open **Project settings → Cloud Messaging → Apple app configuration** and
   upload the `.p8` key with the Key ID and Team ID.
3. **Add app → iOS** with the bundle ID. Download **`GoogleService-Info.plist`** and add it
   to `mobile/ios/Runner/` through Xcode, so it is part of the Runner target.
4. In Xcode, under **Runner → Signing & Capabilities**, add **Push Notifications** and
   **Background Modes → Remote notifications**. These steps are part of D14.

## 4. Backend service account

1. Open **Project settings → Service accounts → Generate new private key**. This downloads a
   JSON file.
2. Encode it as base64 on one line, and keep the JSON file out of the repository:
   - macOS/Linux: `base64 -w0 service-account.json` (on macOS: `base64 -i service-account.json`)
   - PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("service-account.json"))`
3. In `backend/.env`:
   ```
   PUSH_ENABLED=true
   FIREBASE_SERVICE_ACCOUNT_JSON=<the base64 string>
   ```
4. Restart the backend. The log shows `Push enabled (FCM)`. With `PUSH_ENABLED=true` and no
   service account, the backend refuses to start and names the variable.
5. Delete the downloaded JSON file, or store it in a password manager. Anyone who has it can
   send pushes as your project.

## 5. Check that it works (D8 manual QA)

Use two real Android phones, one member and one admin, and a kiosk.

1. Log in on each phone. The app explains why it wants notifications. Tap **Activar**, then
   allow them in the system dialog.
2. In the database, `SELECT "userId", platform FROM "Device";` shows one row per phone.
3. The member scans the kiosk QR. The admin phone gets **Ingreso** and the member phone gets
   **¡Bienvenido, …!**
4. With the app in the background, tap the admin's notification. The member's detail opens.
5. Close the app completely (swipe it away), then send another check-in, or run the daily
   job (next step). Tap the notification: the app starts and opens the right screen.
6. Daily job, outside production only, as an admin:
   `POST /api/v1/admin/jobs/daily-expiry/run`. Running it twice sends nothing new.
7. Log out on one phone. Its `Device` row disappears.

## How it fits together

| Piece | Where |
|---|---|
| Notification texts | `backend/src/modules/notifications/templates.ts` |
| Store + send, invalid-token cleanup | `backend/src/modules/notifications/notifications.service.ts` |
| FCM / log-only sender (`PUSH_ENABLED`) | `backend/src/modules/notifications/push.sender.ts` |
| Daily 08:00 and nightly 23:59 jobs | `backend/src/modules/scheduler/` |
| Device permission, token, banners, taps | `mobile/lib/core/push/` |
| Inbox and bell | `mobile/lib/features/notifications/` |
