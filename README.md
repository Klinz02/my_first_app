# Linksy go

An Android app built with Flutter and Firebase. You can create an account, log in, and add your classes, work shifts and deadlines to a weekly schedule.

These steps assume you're on Windows and your phone is already set up: **Developer options** and **Wireless debugging** are turned on, and the phone runs Android 11 or newer.

## Before you start

You need these installed once:

- **Flutter** (https://docs.flutter.dev/get-started/install/windows)
- **Android Studio** (https://developer.android.com/studio)

Then, in Android Studio, open **More Actions → SDK Manager → SDK Tools**, tick **Show Package Details**, and make sure these are installed:

- **Android SDK Platform-Tools**
- **Android SDK Command-line Tools (latest)**
- **NDK (Side by side) → 28.2.13676358** (release builds fail without it)

To check everything, open Command Prompt and run:

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

adb is installed with Android Studio, but Windows can't find it. Windows only looks for commands in the folders listed in **PATH**, and Android Studio doesn't add adb's folder (`%LOCALAPPDATA%\Android\Sdk\platform-tools`) to that list. Flutter finds the Android SDK by itself, which is why `flutter build` works even when `adb` doesn't.

**Permanent fix:** paste this into a PowerShell terminal (the default in VS Code):

```
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";$env:LOCALAPPDATA\Android\Sdk\platform-tools", "User")
```

Then **close VS Code completely and reopen it**, because terminals only read PATH when they start. Check it worked:

```
adb version
```

If it prints a version number, plain `adb pair` and `adb connect` will work. If it still fails, the folder doesn't exist yet. Install **Android SDK Platform-Tools** from Android Studio (see **Before you start**).

**Quick fix for one-off use:** run adb by its full path. Note that PowerShell and Command Prompt write the path differently.

In **PowerShell**:

```
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" pair 192.168.1.20:41235
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" connect 192.168.1.20:37099
```

In **Command Prompt**:

```
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe pair 192.168.1.20:41235
%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe connect 192.168.1.20:37099
```

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

### Check it works

1. The **Linksy go** welcome screen appears.
2. **Create account** with a name, email and a password of 8+ characters takes you to the home dashboard.
3. On the **Schedule** tab, adding a class makes it show up in the list.

## 3. Install it without the computer (optional)

To get an app file you can keep or share:

```
flutter clean
flutter build apk --release
```

It worked if the last line says `√ Built build\app\outputs\flutter-apk\app-release.apk`. Send that file to any Android phone, open it, and tap **Allow** when Android asks about installing unknown apps.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `Android sdkmanager did not install NDK 28.2.13676358` | Install it from Android Studio (see **Before you start**). If it still fails, delete `%LOCALAPPDATA%\Android\Sdk\ndk\28.2.13676358`, reinstall it, then run `flutter clean`. |
| Yellow `WARNING:` lines about `java.lang.System`, `sdkmanager` or `UseAllWindowsProcessorGroups` | Harmless, ignore them. Only the red `FAILURE:` part matters. |
| Only Windows, Chrome and Edge show in `flutter devices` | The phone isn't connected. Run `adb devices`. If it's empty, repeat step 1, part 4. |
| Phone shows `offline` or `unauthorized` | Run `adb kill-server`, then pair and connect again. |
| `adb connect` fails or times out | University and work networks (often `10.x.x.x` addresses) usually block this. Use a home network or phone hotspot, or skip adb and install the APK from step 3 directly. Make sure both devices are on the same Wi‑Fi. Wireless debugging turns off when the phone changes network, so turn it back on. Allow adb if Windows Firewall asks. School or work Wi‑Fi often blocks this. |
| Login or schedule doesn't load | Check the phone has internet. If it still fails, Email/Password sign-in may be off in the Firebase console, or the Firestore rules may not be deployed. |
| Anything else | Run `flutter doctor -v` and send the output to Sophina. |

## Notes for developers

Firebase is configured by `lib/firebase_options.dart` and `android/app/google-services.json`. Don't paste the contents of either file into messages, and don't commit credentials from other services.
