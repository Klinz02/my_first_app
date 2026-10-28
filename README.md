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

PS C:\Users\Yasir\Documents\filessss\New Folder\linksy Go main front\my_first_app> flutter build apk
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by net.rubygrapefruit.platform.internal.NativeLibraryLoader in an unnamed module (file:/C:/Users/Yasir/.gradle/wrapper/dists/gradle-9.3.1-all/9ot9r568e8zfvvd4mn8rbu1j0/gradle-9.3.1/lib/native-platform-0.22-milestone-29.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module
WARNING: Restricted methods will be blocked in a future release unless native access is enabled

WARNING: The SDK Manager CLI tool (sdkmanager) is deprecated. Android CLI will be used instead.
The 'android' binary can also be found in the cmdline-tools directory, and 'android sdk' is the replacement for 'sdkmanager'.
To learn more about the Android CLI and how to use it, see the documentation (https://d.android.com/tools/agents/android-cli)

OpenJDK 64-Bit Server VM warning: The UseAllWindowsProcessorGroups flag is not supported on this Windows version and will be ignored.
Package ndk not found.
Package 28.2.13676358 not found.

FAILURE: Build failed with an exception.

* Where:
Build file 'C:\Users\Yasir\Documents\filessss\New Folder\linksy Go main front\my_first_app\android\build.gradle.kts' line: 19

* What went wrong:
A problem occurred configuring project ':app'.
> org.gradle.api.GradleException: Android sdkmanager did not install NDK 28.2.13676358 into C:\Users\Yasir\AppData\Local\Android\sdk.

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights from a Build Scan (powered by Develocity).
> Get more help at https://help.gradle.org.

BUILD FAILED in 31s
Running Gradle task 'assembleRelease'...                           38.2s
Gradle task assembleRelease failed with exit code 1
PS C:\Users\Yasir\Documents\filessss\New Folder\linksy Go main front\my_first_app> 