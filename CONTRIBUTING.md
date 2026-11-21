# Contributing to Housie Ka King

You can help by improving documentation, trying the iPad layout, adding a game-rule test, or reporting a problem you can reproduce. Please follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Find something to work on

- Start with an open [good first issue](https://github.com/Hari-Aditya-003/housie/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22). If you plan to take it on, leave a short comment so others can coordinate.
- Search [existing issues](https://github.com/Hari-Aditya-003/housie/issues) before opening a new one. When reporting a bug, include your device or simulator, OS version, app version or commit, and steps to reproduce it.
- For a larger change, describe the use case and scope in an issue before writing the implementation. The [roadmap](ROADMAP.md) has some starting points.

## Set up your checkout

Fork the repository, clone your fork, and create a branch from the current `main`. Follow the [setup steps](README.md#run-the-app) to install CocoaPods dependencies and open `Housie.xcworkspace`. Use the simulator for caller and layout work. Changes to the Cast receiver require a compatible phone or tablet and a configured receiver for a hardware check.

## Run the checks

Run these from the repository root. These checks do not need a simulator or CocoaPods. The core test runner uses Swift 6 or newer.

```sh
swift run HousieCoreTests
./HousieTests/verify_caller_experience.sh
./HousieTests/verify_tv_casting.sh
```

For app changes, also run **Product → Test** in Xcode with an iPad simulator selected. From Terminal, use `xcrun simctl list devices available` to find the ID of an installed iPad simulator. Replace `IPAD_SIMULATOR_ID` below with that ID:

```sh
xcodebuild \
  -workspace Housie.xcworkspace \
  -scheme Housie \
  -destination 'platform=iOS Simulator,id=IPAD_SIMULATOR_ID' \
  -only-testing:HousieUITests \
  test
```

If Terminal is using the standalone Command Line Tools, set `DEVELOPER_DIR` to the `Contents/Developer` folder inside your Xcode installation for the simulator commands. For UI changes, check the affected device sizes and orientations. If you can test on real AirPlay or Cast hardware, record the receiver and what you verified. Identify any checks you skipped in your pull request.

## Open a pull request

1. Keep the change focused. Leave generated Pods, build files, signing changes, and local configuration out of the commit.
2. Push your branch to your fork and open a pull request against `main`.
3. Explain what changed, link the issue if there is one, and describe your checks. For visual changes, include screenshots with the device or simulator and orientation.

First-time contributions are welcome. It’s fine to open a draft PR if you’d like early feedback.
