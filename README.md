# Linksy go Android app

Linksy go is being built with Flutter (Dart) in VS Code. Android is the release target for this plan. The existing Firebase project is initialized in the app and registered for the current Android application ID.

## Current implementation

- Welcome and account screens are present.
- Account creation and sign-in use Firebase Authentication; password reset, session routing, and sign-out are included.
- The home dashboard is a visual shell. Schedule, study planning, groups, messaging, and file sharing remain to be implemented.

## Run from VS Code

1. Open this project folder in VS Code.
2. Use the Flutter device picker to select an Android emulator or connected Android phone.
3. Run `flutter pub get` in the integrated terminal, then choose **Run > Start Debugging** or run `flutter run`.
4. To build an Android APK, run `flutter build apk` in the integrated terminal.

Firebase is configured by `lib/firebase_options.dart` and `android/app/google-services.json`. Do not paste the contents of either configuration file into messages or commit credentials from unrelated services.
