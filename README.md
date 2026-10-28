# Linksy go

An Android app built with Flutter and Firebase. You can create an account, log in, and add your classes, work shifts and deadlines to a weekly schedule.

This guide is for building the app on a Windows laptop and installing it on an Android phone. You don't need a USB cable.

## 1. One-time setup

Install these once:

- **Flutter** (https://docs.flutter.dev/get-started/install/windows)
- **Android Studio** (https://developer.android.com/studio)

In Android Studio, open **More Actions → SDK Manager → SDK Tools**, tick **Show Package Details**, and make sure these are installed:

- **Android SDK Platform-Tools**
- **Android SDK Command-line Tools (latest)**
- **NDK (Side by side) → 28.2.13676358** (the build fails without it)

Then open the project folder in VS Code, open the terminal (**View → Terminal**), and run:

```
flutter doctor
```

The **Flutter** and **Android toolchain** lines should have a green ✓. If it says Android licenses are missing, run `flutter doctor --android-licenses` and type `y` to each one.

## 2. Build the app

In the VS Code terminal, inside the project folder:

```
flutter pub get
flutter build apk --release
```

The first build can take 10–20 minutes. It worked if the last line says:

```
√ Built build\app\outputs\flutter-apk\app-release.apk
```

## 3. Put it on the phone

1. Open the folder with the app file:

   ```
   explorer build\app\outputs\flutter-apk
   ```

2. Send **app-release.apk** to the phone. The easiest way is WhatsApp Web (web.whatsapp.com): open the chat with yourself and drag the file in. Email or Google Drive also work.
3. On the phone, tap the file. If it asks, allow installing unknown apps, then tap **Install**.
4. Open **Linksy go** from the home screen like any other app. You don't need the laptop after this.

The phone needs internet, because accounts and schedules are saved in Firebase.

## 4. Check it works

1. Tap **Create account**. Enter a name, an email and a password of 8+ characters. You should land on the home screen.
2. Go to **Schedule → Add**, add a class for today, and tap **Save**. It should appear in the list and under **Today's commitments** on the home screen.
3. Log out (top right) and log back in. Your class should still be there.

## 5. Getting updates

Pushing code to GitHub does **not** update the app on the phone. When there are new changes:

```
git pull
flutter build apk --release
```

Then send the new **app-release.apk** to the phone and install it over the old one. You stay logged in, and your schedule is kept.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `Android sdkmanager did not install NDK 28.2.13676358` | Install the NDK from Android Studio (see step 1). If it still fails, delete `%LOCALAPPDATA%\Android\Sdk\ndk\28.2.13676358`, install it again, then run `flutter clean` and build again. |
| Yellow `WARNING:` lines about `java.lang.System`, `sdkmanager` or `UseAllWindowsProcessorGroups` | Harmless. Only the red `FAILURE:` part matters. |
| Phone won't install the APK | Allow the app you opened it from (WhatsApp, Files, Chrome) to install unknown apps. If an older version is installed, it updates over it. |
| "Could not sign you in" or schedule won't load | Check the phone has internet. If it still fails, Email/Password sign-in may be off in the Firebase console, or the Firestore rules may not be published. Tell Sophina. |
| Anything else | Run `flutter doctor -v` and send a photo of the output to Sophina. |

## Optional: live testing with `flutter run`

You only need this if you want to see code changes on the phone straight away while coding. To just use the app, steps 2–3 are enough.

This uses **Wireless debugging** (Android 11+). The phone and laptop must be on the same Wi‑Fi, and campus or work Wi‑Fi usually blocks it. Use a home network or a hotspot from a **different** phone.

1. On the phone, turn on Developer options: **Settings → About phone**, tap **Build number** 7 times.
2. In **Developer options**, turn on **USB debugging** and **Wireless debugging**. On Realme phones, also turn on **Disable permission monitoring** (at the bottom).
3. Tap **Wireless debugging → Pair device with pairing code**, and keep that popup open. Use the IP:port **from the popup**:

   ```
   adb pair 192.168.1.20:41235
   ```

   Type the 6-digit code when asked. It should say `Successfully paired`.
4. Close the popup. Use the IP:port from the **main** Wireless debugging screen (it's a different port):

   ```
   adb connect 192.168.1.20:37099
   adb devices
   flutter run
   ```

   Keep the phone unlocked. If the phone shows an install popup, tap **Install**.

Tips:

- The 6-digit code goes after `adb pair`. It is not a port number.
- Ports change whenever Wireless debugging turns off. Always read them fresh from the phone.
- Don't run `adb kill-server` once you're connected, because it disconnects you.

**If it says "adb is not recognized":** Windows can't find adb. Paste this into the VS Code terminal (PowerShell):

```
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";$env:LOCALAPPDATA\Android\Sdk\platform-tools", "User")
$env:Path += ";$env:LOCALAPPDATA\Android\Sdk\platform-tools"
adb version
```

If `adb version` prints a number, it's fixed. If not, install **Android SDK Platform-Tools** (step 1).

## Notes for developers

Firebase is configured by `lib/firebase_options.dart` and `android/app/google-services.json`. Don't paste the contents of either file into messages, and don't commit credentials from other services.
