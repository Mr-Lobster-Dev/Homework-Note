# Homework Note for iPad (and iPhone), with a widget

This folder turns the web app into a real app that you install from your Mac, plus a Home Screen widget showing what is overdue, due today and still to do. The app is the same Homework Note, running from inside the app, so it works offline.

You need: a Mac with a recent **Xcode** (free, from the Mac App Store), your iPad, a USB cable (or the same Wi-Fi), and your **Apple ID** (a free one is fine).

## One-time setup on the Mac

1. Install **Xcode** from the Mac App Store and open it once so it finishes installing.
2. Open the **Terminal** app and paste these lines one at a time. The first installs Homebrew, a tool installer, and asks for your Mac password. The second installs XcodeGen, which builds the Xcode project for you.
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   brew install xcodegen
   ```
3. Download the project: on github.com/Mr-Lobster-Dev/Homework-Note choose **Code → Download ZIP**, then double-click the ZIP to unzip it.
4. Open `ios/project.yml` in TextEdit. Find the line `APP_BUNDLE_ID: com.example.homeworknote` and change `example` to something unique to you, like your name in lowercase letters, for example `com.kenlobster.homeworknote`. Save.
5. In Terminal, go into the `ios` folder and build the project. Type `cd ` (with a space), drag the `ios` folder from Finder into the Terminal window, press Return, then:
   ```
   xcodegen
   open HomeworkNote.xcodeproj
   ```

## Put it on your iPad

1. In Xcode, choose **Xcode → Settings → Accounts**, press **+** and sign in with your Apple ID.
2. In the left list click the blue **HomeworkNote** project, then for **each** of the two targets (HomeworkNote and HomeworkNoteWidget) open **Signing & Capabilities** and pick your name under **Team**.
3. On the iPad: **Settings → Privacy & Security → Developer Mode → on**, then restart when asked.
4. Plug the iPad into the Mac, unlock it and tap **Trust**. At the top of Xcode choose your iPad as the destination, then press the **Play** button.
5. First launch only: on the iPad open **Settings → General → VPN & Device Management**, tap your Apple ID and tap **Trust**. Then open Homework Note.

## Add the widget

Touch and hold an empty spot on the Home Screen, tap **+** at the top left, search **Homework Note**, pick a size and tap **Add Widget**. Small shows two items, medium three, large eight, extra large nine. The widget updates each time you change something in the app, and every hour.

## Good to know

- A **free Apple ID** installs the app for 7 days. After that, plug in the iPad and press Play again. A paid Apple Developer membership ($99 a year) lasts a year and allows TestFlight.
- Your items live inside the app on that iPad and in the widget. The Google sign-in is not included for now. If you set it up later, the same app will use it.
- Links open in Safari. PDF attachments may not open inside the app yet.
- I couldn't build this on my side, because Xcode only runs on a Mac. If Xcode shows a red error, send me a screenshot and I'll fix it.
- After a new version of the web app is pushed, download the project again and press Play to update the app.
