# Linksy go

An Android app built with Flutter and Firebase. You can create an account, log in, and add your classes, work shifts and deadlines to a weekly schedule.

These steps assume you're on Windows and your phone is already set up: **Developer options** and **Wireless debugging** are turned on, and the phone runs Android 11 or newer.

## Before you start

You need these installed once:

- **Flutter** (https://docs.flutter.dev/get-started/install/windows)
- **Android Studio** (https://developer.android.com/studio), with **Android SDK Platform-Tools** ticked under More Actions → SDK Manager → SDK Tools

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

| Problem | Fix |
| --- | --- |
| Only Windows, Chrome and Edge show in `flutter devices` | The phone isn't connected. Run `adb devices`. If it's empty, repeat step 1, part 4. |
| Phone shows `offline` or `unauthorized` | Run `adb kill-server`, then pair and connect again. |
| `adb connect` fails or times out | Make sure both devices are on the same Wi‑Fi. Wireless debugging turns off when the phone changes network, so turn it back on. Allow adb if Windows Firewall asks. School or work Wi‑Fi often blocks this. |
| Login or schedule doesn't load | Check the phone has internet. |
| Anything else | Run `flutter doctor -v` and send the output to Sophina. |
