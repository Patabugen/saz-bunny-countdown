# Changelog

## Unreleased

- App icon — uses the listening bunny as the app icon for Finder, Dock, and app switcher
- Resizable window — drag the bottom-right corner to scale the panel (0.5× to 1.5×, locked 2:1 aspect ratio). Size persists across launches.
- CLI argument support — launch with a time string (e.g. `SazBunnyCountdown "3pm"`) for testing without the URL scheme
- Defer SpeechRecognizer creation until listening mode, avoiding TCC crash when launched from terminal

## 1.1 — 2026-04-07

- Repeat button on the completion screen — restarts the timer targeting the same time-of-day at its next occurrence (e.g. "20 past" repeats at :20 of the next hour)

## 1.0.0 — 2026-03-27

- Floating countdown timer pinned to the top-right corner, always on top
- Voice input via on-device speech recognition
- Smart time parsing: `4:20`, `4:20 PM`, `16:20`, spoken words like "five twenty", relative phrases like "20 past" / "10 to"
- URL scheme: `open saz://4:20`
- Siri and Shortcuts integration
- "Saz Bunny" theme with bunny mascot and animated colour transitions
- Remembers which screen it was last shown on
