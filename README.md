# Housie

A native SwiftUI Housie (Tambola) caller for iPhone and iPad, designed for Indian family gatherings, festivals, and community events.

## Features

- Random, non-repeating calls from 1 to 90
- Animated ball draw with spoken number announcements
- English and Telugu system voices
- Automatic calling with 4, 6, 8, or 10-second intervals
- Pause, play, manual **Next Ball**, repeat, and reset controls
- A live 1–90 board that keeps called numbers illuminated
- Traditional random 3 × 9 tickets with 15 numbers
- Claim checks for Early Five, Top/Middle/Bottom Line, and Full House
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

## Verify the game engine

The shared Housie engine has a lightweight command-line verification harness:

```sh
swift run HousieCoreTests
```

## Project structure

```text
Housie/
├── App/                 App entry point and caller state
├── DesignSystem/        Colors and reusable card styling
├── Features/
│   ├── Caller/          Ball caller and 1–90 board
│   ├── Tickets/         Ticket generation and claim checks
│   └── Rules/           How-to-play guide
├── HousieCore/          Tested game and ticket rules
└── Resources/           App icon and asset catalog
```

## Privacy

Housie works fully offline. It does not collect personal data, show ads, or require an account.
