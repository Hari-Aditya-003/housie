# Capturing Housie Ka King screenshots

The top-level [README](../../README.md#screenshots) has three slots for actual app images. Add captures from a build of this repository and replace the corresponding pending row with a relative image link and concise alt text. Record the device or simulator, OS version, and orientation in the PR.

| Suggested file | What to capture |
| --- | --- |
| `ipad-caller-landscape.png` | Open **Caller** on an iPad in landscape. Tap **Next Ball** a few times so the current ball, called-number history, and highlights on the 1–90 board are visible. |
| `iphone-caller-portrait.png` | Take a portrait capture after a few draws. Show the current ball, history, and caller controls. |
| `google-cast-tv-board.png` | Follow the [Google Cast setup](../../README.md#set-up-google-cast) on physical devices. Capture the receiver board after a few calls and note the TV or receiver model. |

In Simulator, use **File → Save Screen** or run `xcrun simctl io booted screenshot /path/to/image.png` with a single simulator booted. Check that notifications, personal account details, and device or network names are out of frame. A local preview of the receiver can help when working on layout, but the TV slot is for a demonstrated Cast session.
