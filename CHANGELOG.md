# Changelog

## 1.1.0 — 2026-03-26

### Added

- Test suite using Swift Testing framework with 4 test suites:
  - TimeParser tests: standard formats, bare numbers, AM/PM edge cases, ambiguous resolution, night hours confirmation, invalid inputs
  - SpeechTimeExtractor tests: digit patterns, word numbers, compound words, AM/PM handling, passthrough
  - URLTimeParser tests: hour-only, hour:minute (host+port reconstruction), 24-hour, invalid schemes
  - UI snapshot tests using swift-snapshot-testing: focused/unfocused countdown view, listening view states

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
