# Linksy go

An Android app built with Flutter and Firebase. You can create an account, log in, and add your classes, work shifts and deadlines to a weekly schedule.

These steps assume you're on Windows and your phone is already set up: **Developer options** and **Wireless debugging** are turned on, and the phone runs Android 11 or newer.

## Before you start

You need these installed once:

- **Flutter** (https://docs.flutter.dev/get-started/install/windows)
- **Android Studio** (https://developer.android.com/studio), with **Android SDK Platform-Tools** ticked under More Actions → SDK Manager → SDK Tools

<<<<<<< HEAD
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
=======
To check, open Command Prompt and run:

```
flutter doctor
```

The **Flutter** and **Android toolchain** lines should have a green ✓. If Android licenses are missing, run `flutter doctor --android-licenses` and type `y` to each one.

## 1. Connect your phone over Wi‑Fi

Your phone and computer must be on the **same Wi‑Fi network**.

1. On the phone, open **Settings → Developer options → Wireless debugging**, and make sure it's on.
2. Tap **Pair device with pairing code**. Leave that screen open. It shows an IP address and port (like `192.168.1.20:41235`) and a 6-digit code.
3. On the computer, open Command Prompt and run the command below, using the IP and port from your phone. Type the 6-digit code when it asks.

   ```
   adb pair 192.168.1.20:41235
   ```

4. Close the popup on the phone. The main Wireless debugging screen now shows **IP address & port** with a **different** port number. Use that one:

   ```
   adb connect 192.168.1.20:37099
   ```

   It should say `connected to ...`.

You only need to pair (step 3) the first time. Next time, just do step 4. Check the port again, because it changes.

### If it says "adb is not recognized"

Use the full path to adb instead of just `adb`:

```
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe pair 192.168.1.20:41235
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe connect 192.168.1.20:37099
```

To make plain `adb` work, add that folder to PATH. Press Start, type **environment variables**, open **Environment Variables**. Under *User variables*, select **Path → Edit → New**, paste `%LOCALAPPDATA%\Android\Sdk\platform-tools`, and click OK. Then close and reopen Command Prompt.

## 2. Run the app

In Command Prompt, go to this project folder and run:

```
flutter pub get
flutter devices
```

Your phone should be in the list (not just Windows, Chrome and Edge). Then:

```
flutter run
```

The first run takes a few minutes. When it's done, Linksy go opens on your phone and stays installed. While it's running, press `r` in Command Prompt to reload after a code change, or `q` to quit.

**Using VS Code instead:** open the project folder, pick your phone in the device selector at the bottom right, and press **F5**.

## 3. Install it without the computer (optional)

To get an app file you can keep or share:

```
flutter build apk --release
```

The file is `build\app\outputs\flutter-apk\app-release.apk`. Send it to any Android phone, open it, and tap **Allow** when Android asks about installing unknown apps.

## Troubleshooting