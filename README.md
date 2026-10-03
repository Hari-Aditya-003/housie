# Housie

A native SwiftUI Housie (Tambola) caller for iPhone and iPad, designed for Indian family gatherings, festivals, and community events.

## Features

- Random, non-repeating calls from 1 to 90
- Polished animated ball draw with smooth English announcements
- Automatic calling with 4, 6, 8, or 10-second intervals
- Pause, play, manual **Next Ball**, repeat, and reset controls
- A complete 1–90 board plus a visible history of every called number
- AirPlay control for Apple TV and compatible televisions
- Compact in-app **How It Works** guide
- Adaptive layouts for both iPhone and iPad
- VoiceOver-friendly labels and Dynamic Type-friendly UI

## Requirements

- Xcode 16 or newer
- iOS/iPadOS 17 or newer
- No third-party dependencies

## Run the app

1. Open `Housie.xcodeproj` in Xcode.
2. Select the **Housie** scheme.
3. Choose an iPhone or iPad simulator.
4. Press **Run**.

Before installing on a physical device, choose your Apple Developer team under **Signing & Capabilities** and change the bundle identifier if needed.

## Run the tests

Verify the game rules and product requirements from Terminal:

```sh
swift run HousieCoreTests
HousieTests/verify_caller_experience.sh
```

Run the interaction tests on an iPad simulator from Xcode with **Product → Test**, or from Terminal:

```sh
xcodebuild \
  -project Housie.xcodeproj \
  -scheme Housie \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' \
  -only-testing:HousieUITests \
  test
```

## Project structure

```text
Housie/
├── App/                 App entry point and caller state
├── DesignSystem/        Colors and reusable card styling
├── Features/
│   ├── Caller/          Ball caller and 1–90 board
│   └── Rules/           Compact app guide
├── HousieCore/          Tested game and ticket rules
└── Resources/           App icon and asset catalog
HousieUITests/           Caller interaction and accessibility tests
```

## Privacy

Housie works fully offline. It does not collect personal data, show ads, or require an account.
