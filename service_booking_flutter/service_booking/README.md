# Service Booking — Flutter app

Connects to the real Supabase project `booking-app` (`lybbdqwgfjekrqhhgdkf`).
Credentials are already filled in at `lib/core/config/supabase_config.dart`
using the **publishable** key (safe for the client — never put the
service-role key here).

## What's implemented in this batch

- Guest browsing: categories → services → locations → date → time slot,
  no account required.
- Auth gate exactly at "Confirm booking" (Google OAuth + phone/OTP via
  Supabase Auth). Selections survive the sign-in interruption.
- Booking creation, cancellation, and My Bookings — all calling your
  existing `create_booking` / `cancel_booking` / `reschedule_booking` RPCs,
  never writing to `bookings`/`availability_slots` directly.
- Theme matching the reference UI: peach background, near-black rounded
  cards, orange primary actions.

## Not yet built (next batch)

- Provider dashboard (today's bookings, confirm/cancel with audit warning)
- Super user / admin dashboard (services, locations, providers, assignments,
  slots, users)
- Push notifications wiring (the `notifications` table + realtime channel
  already exist server-side; client subscription isn't wired up yet)
- Windows-specific OAuth deep-link handling (see below)

## One-time setup on YOUR machine (this sandbox has no internet, so none of
this could be run here)

1. Install Flutter (stable channel) and make sure `flutter doctor` is clean
   for Android and Windows desktop targets.
2. From this project's root, generate the native platform folders (not
   included here since they require the Flutter SDK to scaffold):
   ```
   flutter create --platforms=android,windows .
   ```
   This won't overwrite `lib/` or `pubspec.yaml`.
3. `flutter pub get`
4. Android deep link for Google OAuth — add to
   `android/app/src/main/AndroidManifest.xml` inside the main `<activity>`:
   ```xml
   <intent-filter>
     <action android:name="android.intent.action.VIEW" />
     <category android:name="android.intent.category.DEFAULT" />
     <category android:name="android.intent.category.BROWSABLE" />
     <data android:scheme="com.servicebooking.app" android:host="login-callback" />
   </intent-filter>
   ```
5. In your Supabase Dashboard → Authentication → URL Configuration, add
   `com.servicebooking.app://login-callback` as a Redirect URL, and enable
   the Google and Phone providers under Authentication → Providers (Phone
   needs an SMS provider like Twilio configured).
6. Windows: `signInWithOAuth` opens the system browser; Windows custom URI
   scheme registration works differently from Android (via registry / MSIX
   manifest `Extensions`) — flag this back to me once you're building the
   Windows target and I'll write that piece specifically, since it needs
   the actual packaging setup to hook into correctly.
7. Run: `flutter run -d windows` or `flutter run -d <android-device-id>`.

## Verify yourself (I can't run these here — no network/Flutter SDK in
this sandbox)

```
flutter analyze
flutter build apk --release
flutter build windows --release
```
