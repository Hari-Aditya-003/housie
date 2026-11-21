# Housie Ka King

**Run a game of Housie (Tambola) from your iPhone or iPad.** Housie Ka King is an open-source SwiftUI number caller built for family gatherings, festivals, and community events.

[![CI](https://github.com/Hari-Aditya-003/housie/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Hari-Aditya-003/housie/actions/workflows/ci.yml)
[![GitHub stars](https://img.shields.io/github/stars/Hari-Aditya-003/housie)](https://github.com/Hari-Aditya-003/housie/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Hari-Aditya-003/housie)](https://github.com/Hari-Aditya-003/housie/forks)
[![MIT license](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

[Run locally](#run-the-app) · [Contribute](CONTRIBUTING.md) · [Find a first issue](https://github.com/Hari-Aditya-003/housie/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) · [Roadmap](ROADMAP.md)

## Features

- Call all 90 numbers in random order, without repeats. Tap **Next Ball** to draw manually or **Play** to call every 4, 6, 8, or 10 seconds.
- Hear each number spoken in English, repeat the current call, or turn speech off in **Caller settings**.
- Follow called numbers on the 1–90 board and in the current game’s history, displayed newest first. Reset the board to start a new game.
- Use the app in portrait or landscape on iPhone and iPad. The caller and board appear side by side when space allows.
- Open the built-in **How It Works** guide or use the TV controls for AirPlay routing and [Google Cast board sharing](#set-up-google-cast).

## Screenshots

| View | Capture status |
| --- | --- |
| iPad caller and 1–90 board | Pending. Show the caller and highlighted board after a few draws. |
| iPhone caller | Pending. Show the current ball, controls, and called-number history in portrait. |
| Google Cast TV board | Pending. Show the board on a connected receiver during a real cast session. |

See the [screenshot guide](Documentation/Screenshots/README.md) to help fill these slots.

## Run the app

You’ll need a Mac with Xcode 26 or newer, an iOS simulator runtime, and CocoaPods 1.16.2 to match `Podfile.lock`. The app targets iOS and iPadOS 17 and later. The simulator can run the caller with the default Cast receiver placeholder.

```sh
git clone https://github.com/Hari-Aditya-003/housie.git
cd housie
pod install --deployment
open Housie.xcworkspace
```

In Xcode, select the **Housie** scheme, choose an iPhone or iPad simulator, and press **Run**. For a physical device, select your Apple Developer team under **Signing & Capabilities** and change the bundle identifier if required. Keep those personal signing changes local.

## Set up Google Cast

The iOS sender can share the live board with a Chromecast, Google TV, or other Google Cast receiver. To try it on hardware:

1. Host the contents of [GoogleCastReceiver/](GoogleCastReceiver/) at a public HTTPS URL.
2. Register that URL as a **Custom Web Receiver** in the [Google Cast SDK Developer Console](https://cast.google.com/publish/).
3. In the **Housie** target’s Build Settings, replace `YOUR_GOOGLE_CAST_RECEIVER_APP_ID` under **Google Cast Receiver App ID** for the configuration you’re running.
4. Install on a physical iPhone or iPad, join the same Wi-Fi network as the receiver, and allow local network access when prompted.

The sender publishes called numbers, the current number, and game status on `urn:x-cast:com.housie.board`. The receiver highlights the current and previous calls. Verify device discovery and board updates on physical hardware.

## Test and contribute

```sh
swift run HousieCoreTests
./HousieTests/verify_caller_experience.sh
./HousieTests/verify_tv_casting.sh
```

For interaction tests, choose an iPad simulator and use **Product → Test**, or follow the [command-line instructions](CONTRIBUTING.md#run-the-checks). GitHub Actions runs the core checks, a simulator build, and the iPad UI suite. The casting script checks source configuration and the sender/receiver contract.

Start with the [contributing guide](CONTRIBUTING.md) and [code of conduct](CODE_OF_CONDUCT.md). Documentation, accessibility feedback, and small test improvements are welcome.

| Where | What you’ll find |
| --- | --- |
| [Housie/Features/](Housie/Features/) | SwiftUI caller, number board, and in-app guide |
| [Housie/App/](Housie/App/) | App entry point, caller state, timer, and speech |
| [Housie/HousieCore/](Housie/HousieCore/) | Game and ticket rules. Ticket generation and prize checks are core code only. |
| [Housie/Casting/](Housie/Casting/) and [GoogleCastReceiver/](GoogleCastReceiver/) | Cast sender and TV web receiver |
| [HousieTests/](HousieTests/) and [HousieUITests/](HousieUITests/) | Game rules, configuration checks, and iPad interactions |
| [Documentation/](Documentation/) | Owner guide and screenshot instructions |

The caller runs offline and needs no account. TV sharing uses a network connection, and Google Cast also needs the hosted receiver described above. Housie Ka King is available under the [MIT license](LICENSE).
