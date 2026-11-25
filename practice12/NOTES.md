# NOTES: Practice 12

## Level 1. Package verdicts
(order: publisher, last release, platforms, pub points, issues vs commits, dependencies, licence)

1. **shared_preferences**: verified publisher flutter.dev, version 2.5.x (last release: CHECK month/year),
   Android/iOS/Web/macOS/Linux/Windows, 160 points, open issues are triaged and commits are recent,
   depends only on its own platform packages (_android, _foundation, ...), BSD-3-Clause.
2. **flutter_secure_storage**: verified publisher steenbakker.dev, 11.2.0 released September 2026,
   all six platforms, 160 points, issues exist but commits are recent,
   depends on its own darwin/linux/web/windows packages and meta, BSD-3-Clause.
3. **path_provider**: verified publisher flutter.dev, last release CHECK month/year,
   all six platforms, 160 points (CHECK), maintained in the flutter/packages repo with recent commits,
   depends only on its own platform packages, BSD-3-Clause.
4. **image_picker**: verified publisher flutter.dev, last release CHECK month/year,
   Android, iOS, Web, macOS, Windows, Linux (CHECK), 160 points (CHECK), many open issues but
   very recent commits (flutter/packages), depends on its own platform packages, BSD-3-Clause.
5. **permission_handler**: verified publisher baseflow.com, 13.0.2 released about two months ago,
   Android, iOS, Web, Windows, 160 points, issues open but still maintained,
   depends on permission_handler_android/_apple/_html/_windows and meta, MIT.
6. **url_launcher**: verified publisher flutter.dev, last release CHECK month/year,
   all six platforms, 160 points (CHECK), recent commits in flutter/packages,
   depends only on its own platform packages, BSD-3-Clause.

## Level 1. Caret and pubspec.lock
- `^1.2.0` means `>=1.2.0 <2.0.0`.
  It accepts 1.2.0, 1.2.1, 1.5.0, 1.99.0.
  It refuses 1.1.9 (older than the minimum) and 2.0.0 (a new major version may break the API).
- Exact version of http in pubspec.lock: __ (copy from your file).
- pubspec.lock is committed for an app, so that every machine and every CI build resolves exactly the
  same versions as mine and the build is reproducible. (For a library it is not committed,
  because the people who use the library must be free to resolve versions themselves.)
- Break test: http: 1.2.0 without the caret pins exactly 1.2.0, and `flutter pub outdated`
  shows all newer versions as unavailable. Caret put back.
- `flutter pub outdated`: package __ could be newer, but it was not upgraded because
  __ (paste the reason from your output, e.g. the Flutter SDK pins it, or the new major version
  does not fit the current constraint).

## Level 3. Storage
- `prefs.setString('token', ...)` would put the token in a plain file in the app folder:
  XML (shared_prefs) / DataStore file on Android, plist (NSUserDefaults) on iOS. That file is not encrypted.
  It can be read from a backup (adb backup / iTunes backup), by anyone with root or jailbreak,
  or from a stolen phone connected by cable. A token lets someone be you, so it goes to
  Keychain (iOS) / Keystore (Android) through flutter_secure_storage.
- iOS surprise: Keychain items can survive uninstalling the app, so after a reinstall the old token
  may still be there and the user is "already signed in".
- Android surprise: the Keystore key can be lost when the lock screen is removed or reset,
  and then the data cannot be decrypted. That is why SecureStore.readToken catches PlatformException
  and treats it as "signed out".

## Level 5. Permissions
- Android emulator: the system "Don't allow" is shown, I tap No twice, and on the next tap there is no
  system dialog, my own dialog appears at once (permanentlyDenied), "Open settings" opens the
  permission page of the app. On some Android versions the result is permanentlyDenied already
  after the second No.
- iOS: iOS asks only once. After the first "Don't Allow" the status is permanentlyDenied, and the dialog
  never appears again, so the only way is openAppSettings(). One No is enough.
- The fourth Photos state is `limited` (the user allowed only the selected photos).
  The full list: denied, granted, restricted, limited, permanentlyDenied (plus provisional for notifications).
- launchUrl(Uri.parse('kbtu.edu.kz')) without a scheme returns false and nothing opens.
  With `https://` the browser opens.

## Defence sentence
Every device API answers with an await and a "no" (null / false / denied).
I handle the No, and the feature keeps working without the photo.