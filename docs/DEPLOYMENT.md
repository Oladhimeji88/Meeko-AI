# Production Deployment Guide

## 1. Versioning
Bump `version: x.y.z+build` in `pubspec.yaml`. The build number must increase
for every store upload.

## 2. App identity
- **Android applicationId:** `com.tech4mation.pixelbuddy_clock`
  (`android/app/build.gradle.kts`).
- **iOS bundle id:** set in Xcode → Runner → Signing & Capabilities.
- Update display name: Android `android:label`, iOS `CFBundleDisplayName`.

## 3. App icons & splash
- Add a 1024×1024 master icon and run `flutter_launcher_icons`
  (see `docs/ASSETS.md`).
- Optional splash: `flutter_native_splash`.

## 4. Android release signing
Create `android/key.properties` (do **not** commit):

```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/upload-keystore.jks
```

Generate a keystore:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

Wire it into `android/app/build.gradle.kts` (replace the debug signingConfig in
the `release` block with one reading `key.properties`). Then:

```bash
flutter build appbundle --release
```

Upload the `.aab` to the Play Console → create a release → roll out.

## 5. iOS release
- Set the Signing Team and a distribution profile in Xcode.
- `flutter build ipa --release`.
- Upload via Xcode Organizer or `xcrun altool` / Transporter to App Store Connect.
- Complete privacy nutrition labels: location, microphone, and (if added) any
  analytics. The Info.plist usage strings are already present.

## 6. Pre-submission checklist
- [ ] Real release keystore / distribution cert configured.
- [ ] Branded app icon + screenshots for both stores.
- [ ] `flutter analyze` clean, `flutter test` passing.
- [ ] Weather + AI keys are user-supplied (no secrets bundled in the binary).
- [ ] Privacy policy URL (required because of microphone + location).
- [ ] Test alarms fire from cold start (reboot) on a physical Android device.
- [ ] Test on smallest + largest supported screen for layout.

## 7. Premium / monetization (future)
Premium is gated by `AppSettings.isPremium`. To monetize, integrate
`in_app_purchase`, validate receipts server-side, and flip `setPremium(true)` on
entitlement. No payment gateway is wired in this build by design.
