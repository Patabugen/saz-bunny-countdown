# Countdown Timer

A minimal floating countdown timer for macOS. Tell it when you need to finish, and it stays visible in the corner of your screen until time's up.

Runs as an invisible app — no dock icon, no menu bar. Just a small always-on-top widget.

## Requirements

- macOS 13.0 or later
- Xcode 15+ (to build from source)
- Microphone permission (for voice input)

## Building

```bash
xcodebuild -scheme CountdownTimer -destination 'platform=macOS' SYMROOT=build
open build/Debug/CountdownTimer.app
```

Or open `CountdownTimer.xcodeproj` in Xcode and press Cmd+R.

## Usage

### Voice input

Launch the app without any arguments. A small widget appears asking **"When should I finish?"** and starts listening. Say a time:

- "five twenty"
- "3:45 PM"
- "nine o'clock"
- "seven thirty"
- "four PM"

The app uses on-device speech recognition — nothing is sent to the cloud. It waits for 1.5 seconds of silence before processing your input.

### URL scheme

Set a timer from Terminal, scripts, or other apps:

```bash
open countdown://4:20
open countdown://16:30
open countdown://5
```

### Siri / Shortcuts

The app registers with App Intents. You can trigger it from Shortcuts or say:

- "Start a countdown in CountdownTimer"
- "Start CountdownTimer"

Siri will open the app in voice input mode. You can also create a Shortcut that passes a specific time to the "Countdown Timer" action.

### Time formats

The parser accepts a wide range of formats:

| Input | Interpreted as |
|-------|---------------|
| `4:20 PM` | 4:20 PM |
| `4:20 AM` | 4:20 AM |
| `16:20` | 4:20 PM (24-hour) |
| `4:20` | Whichever of 4:20 AM/PM is nearest in the future |
| `520` | 5:20 (bare digits) |
| `1630` | 4:30 PM (bare digits, 24-hour) |
| `4 PM` | 4:00 PM |
| `4` | Whichever of 4 AM/PM is nearest in the future |

When a time is ambiguous (no AM/PM and hour is 1-12), the app picks whichever occurrence is closest in the future. For example, if it's currently 2 PM and you say "4", it picks 4 PM today, not 4 AM tomorrow.

If the resolved time falls between 10 PM and 9 AM, a confirmation dialog appears.

### While the timer is running

- The countdown displays as `H:MM:SS` or `MM:SS`
- The target time is shown below (e.g. "until 4:20 PM")
- When time's up, a gentle "Glass" sound plays and the digits change color
- The timer stays visible until you dismiss it
- Click **Quit** (or press Enter when focused) to dismiss and quit the app
- Click the **X** button in the top-right corner to dismiss

### Focus and appearance

- Click the widget to focus it — a warm border appears
- Click elsewhere to unfocus — the border fades
- The widget remembers which screen it was on and returns there next launch
- Re-opening the app while a timer is running focuses the existing widget instead of creating a new one

## Running tests

```bash
xcodebuild test -scheme CountdownTimer -destination 'platform=macOS'
```

The test suite includes:

- **TimeParser** — format parsing, AM/PM resolution, night hours, invalid inputs
- **SpeechTimeExtractor** — voice transcript to time string conversion
- **URLTimeParser** — URL scheme parsing
- **FloatingPanel** — focus state management
- **Snapshots** — UI appearance for countdown and listening views (uses [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing))

Snapshot tests record reference images on first run. If you change the UI, delete `CountdownTimerTests/__Snapshots__/` and run tests twice (first run records, second run verifies).

## Project structure

```
CountdownTimer/
  AppDelegate.swift          App lifecycle, window management, view routing
  CountdownTimerApp.swift    @main entry point
  FloatingPanel.swift        Borderless floating NSWindow + focus tracking
  CountdownView.swift        Timer display (digits, target time, quit button)
  ListeningView.swift        Voice input prompt
  CountdownViewModel.swift   Timer logic, formatting, sound
  SpeechRecognizer.swift     On-device speech recognition via SFSpeechRecognizer
  TimeParser.swift           Time string parsing and AM/PM resolution
  SpeechTimeExtractor.swift  Extracts time from natural speech transcripts
  URLTimeParser.swift        Extracts time from countdown:// URLs
  CountdownIntent.swift      Siri / Shortcuts integration
  ClayTheme.swift            Visual constants (colors, dimensions, shadows)
  Info.plist                 App configuration (LSUIElement, URL scheme, permissions)
```

## License

Personal use.
