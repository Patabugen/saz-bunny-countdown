# Changelog

## 1.4.0 — 2026-03-27

### Changed

- Rebranded app from "Countdown Timer" to "Saz Bunny"
- URL scheme changed from `countdown://` to `saz://`
- Siri phrases updated to reference "Saz Bunny" (e.g. "Start a timer in Saz Bunny")
- Privacy permission descriptions updated to use "Saz Bunny" name
- Shared `SazBunnyLayout` view extracts common bunny-on-right layout across all screens
- Consistent bunny sizing across listening, countdown, and expired screens
- Saz Bunny is now the default theme

### Added

- `SazBunnyError` image asset for error states
- Four named image assets: SazBunnyListening, SazBunnyCountdown, SazBunnyExpired, SazBunnyError

## 1.3.0 — 2026-03-27

### Added

- Saz-Bunny theme with full colour palette derived from the mascot (purple, teal, pink)
- Bunny mascot appears on the ask screen, peeking from the right edge
- Small bunny icon on the countdown screen (top-right column)
- Large bunny appears on the expired screen, peeking from the left
- Background shifts from soft lavender (#F5F0FF) to soft pink (#FDF2F8) on expiry
- Animated colour transition when timer expires (0.3s ease-in-out)
- Circular close button with theme-aware colours (purple/pink depending on state)
- Three image assets in Xcode asset catalogue: SazBunny, SazBunnySmall, SazBunnyPeekExpired
- Snapshot tests for all three SazBunny states (listening, countdown, expired)

### Changed

- Theme struct extended with expired-state colour tokens and interactive element colours
- ListeningView and CountdownView now branch layout by theme (Saz Bunny vs Classic)
- Updated `foregroundColor` to `foregroundStyle` throughout views (modern SwiftUI API)

## 1.2.0 — 2026-03-26

### Changed

- Visual reskin: "Clay Morph" style with soft rounded shapes and earthy color palette
- Window size expanded from 240×100 to 320×160 for better readability
- Timer digits now use SF Pro Rounded Bold with gradient fill and soft shadows
- Background changed from translucent material to warm off-white (#F3EFEA)
- Focus border changed from system accent blue to clay orange
- "Finished" state uses warm terracotta instead of system red
- All fonts changed to SF Pro Rounded design
- Corner radius increased from 12pt to 24pt for softer appearance

### Added

- `ClayTheme` struct centralizing all visual constants (colors, dimensions, shadows)
- Inner shadow and top-left highlight effects on digit background pill
- Capsule-shaped Quit button with clay styling

## 1.1.0 — 2026-03-26

### Added

- Test suite using Swift Testing framework with 4 test suites:
  - TimeParser tests: standard formats, bare numbers, AM/PM edge cases, ambiguous resolution, night hours confirmation, invalid inputs
  - SpeechTimeExtractor tests: digit patterns, word numbers, compound words, AM/PM handling, passthrough
  - URLTimeParser tests: hour-only, hour:minute (host+port reconstruction), 24-hour, invalid schemes
  - UI snapshot tests using swift-snapshot-testing: focused/unfocused countdown view, listening view states
  - FloatingPanel focus state test: verifies becomeKey/resignKey update isFocused

### Fixed

- Focus border (blue outline) was never appearing — FloatingPanel was missing becomeKey/resignKey overrides to update focusState

### Changed

- Extracted `SpeechTimeExtractor` struct from AppDelegate for testability
- Extracted `URLTimeParser` struct from AppDelegate for testability

## 1.0.0 — 2026-03-26

### Features

- Floating countdown timer that appears in the top-right corner, always on top
- Smart time parsing: accepts formats like `4:20`, `4:20 PM`, `16:20`
- Ambiguous times (no AM/PM) resolve to the nearest future occurrence
- Confirmation dialog when setting timers for late night / early morning (10 PM–9 AM)
- Gentle "Glass" sound plays when the countdown reaches zero
- Timer stays visible after completion until dismissed
- Dismiss by clicking anywhere on the widget or the X button
- URL scheme support: `open countdown://4:20`
- Siri / Shortcuts integration via App Intents
- Runs as an accessory app (no dock icon, no menu bar)

### Added

- Voice input: when launched without a time, shows "When should I finish?" and listens via microphone using on-device speech recognition
- Handles both spoken digit times ("5:20") and word times ("five twenty")
- Timer remembers which screen it was on and re-appears there on next launch
- Press Space to restart with voice input while a timer is running
- Hint text "Esc to quit, Space to restart" shown on the countdown view
- Re-opening the app focuses the existing window instead of creating a new one
- Press Escape to dismiss the timer when the window is focused

### Changed

- Applied Swift 6 best practices: `@MainActor` isolation on `AppDelegate`, `CountdownViewModel`, `SpeechRecognizer`, `CountdownView`, and `ListeningView`
- Replaced `DispatchQueue.main.async` with `@MainActor`-isolated methods and `Task { @MainActor in }` for compiler-verified thread safety
- Replaced `DispatchQueue.main.asyncAfter` timing hack with structured `Task.sleep`
- Esc and Space now only work when the timer panel is focused (click to focus)
- Accent-colored border appears when the panel is focused, fades when unfocused
- "Esc to quit, Space to restart" hint only shown when focused
- Escape now fully terminates the app (not just hides the window)
- Fixed: keyboard shortcuts now actually work — clicking the panel temporarily activates the app so it can receive key events, then reverts to accessory mode when unfocused
- Replaced keyboard shortcuts with a visible "Quit" button below the timer (Enter to activate)
- Removed Escape key handling (unreliable in accessory/floating window context)

### Fixed

- URL scheme now correctly handles times with minutes (e.g., `countdown://5:20`) — previously the URL parser split host and port, dropping the minutes
- Time parser now handles bare 3-4 digit numbers (e.g., `520` → 5:20, `1630` → 16:30) — fixes speech recognition transcribing "five twenty" as "520"
