# Housie

A native SwiftUI Housie (Tambola) caller for iPhone and iPad, designed for Indian family gatherings, festivals, and community events.

## Features

- Random, non-repeating calls from 1 to 90
- Polished animated ball draw with smooth English announcements
- Automatic calling with 4, 6, 8, or 10-second intervals
- Pause, play, manual **Next Ball**, repeat, and reset controls
- A complete 1–90 board plus a visible history of every called number
- AirPlay control for Apple TV and compatible televisions
- Google Cast control and live-board synchronization for Chromecast, Android TV, and Google TV
- Compact in-app **How It Works** guide
- Adaptive layouts for both iPhone and iPad
- VoiceOver-friendly labels and Dynamic Type-friendly UI

## Requirements

- Xcode 16 or newer
- iOS/iPadOS 17 or newer
- CocoaPods 1.16 or newer
- A registered Google Cast Receiver App ID for Android/Google TV casting

## Run the app

1. Run `pod install` in the repository folder.
2. Open `Housie.xcworkspace` in Xcode.
3. Select the **Housie** scheme.
4. Choose an iPhone or iPad simulator.
5. Press **Run**.

Before installing on a physical device, choose your Apple Developer team under **Signing & Capabilities** and change the bundle identifier if needed.

## Enable Android and Google TV casting

Google Cast requires a small receiver website because the Housie board is interactive content rather than a video. The ready-to-host receiver is in `GoogleCastReceiver/`.

1. Host `GoogleCastReceiver/` at a public HTTPS URL.
2. Register that URL as a **Custom Web Receiver** in the [Google Cast SDK Developer Console](https://cast.google.com/publish/).
3. Copy the resulting Receiver App ID.
4. In Xcode, open the **Housie** target's Build Settings and replace `YOUR_GOOGLE_CAST_RECEIVER_APP_ID` in **Google Cast Receiver App ID** for Debug and Release.
5. Build and install the app on a physical iPhone or iPad connected to the same Wi-Fi network as the TV.

The iOS sender uses Google's official Cast button and sends every draw, pause, play, and reset over `urn:x-cast:com.housie.board`. The receiver keeps all 90 numbers visible and highlights the current and previously called numbers. Simulator tests verify the UI and message contract; final device discovery requires physical Cast hardware and iOS local-network permission.

## Run the tests

Verify the game rules and product requirements from Terminal:

```sh
swift run HousieCoreTests
HousieTests/verify_caller_experience.sh
HousieTests/verify_tv_casting.sh
```

Run the interaction tests on an iPad simulator from Xcode with **Product → Test**, or from Terminal:

```sh
xcodebuild \
  -workspace Housie.xcworkspace \
  -scheme Housie \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' \
  -only-testing:HousieUITests \
  test
```

## Project structure

```text
Housie/
├── App/                 App entry point and caller state
├── Casting/             Google Cast sender and live-board channel
├── DesignSystem/        Colors and reusable card styling
├── Features/
│   ├── Caller/          Ball caller and 1–90 board
│   └── Rules/           Compact app guide
├── HousieCore/          Tested game and ticket rules
└── Resources/           App icon and asset catalog
HousieUITests/           Caller interaction and accessibility tests
GoogleCastReceiver/      Custom Chromecast/Google TV web receiver
```

## Privacy

Housie works fully offline. It does not collect personal data, show ads, or require an account.
