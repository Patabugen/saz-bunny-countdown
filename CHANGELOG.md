# Changelog

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
