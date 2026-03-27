# Saz-Bunny Countdown Timer - UI Redesign

## Overview

Add a theme to the Countdown Timer macOS app with a new colour palette and layout derived from the Saz-Bunny mascot. The mascot is a vivid 3D-rendered purple and cyan bunny with pink ear accents, green eyes, and a pocket watch - the UI should feel like her world.

This theme is called "Saz Bunny"

The owner of this project does not know Swift. Do not ask them to make code changes - make all changes yourself, explain what you did, and flag anything that needs manual intervention (like replacing image assets).

The owner is a developer and does want to make sure the code you generate is good and maintainable. Ask before making archetectual decisions and explain the pros and cons (e.g. extra permissiosn or dependencies).

Everything should be tested and testable.

## Project context

- This is a macOS SwiftUI app (macOS 13+, Xcode 15+, Swift)
- It's a small floating always-on-top countdown timer widget - compactness matters
- It uses the `swift-snapshot-testing` package for snapshot tests
- The project has an existing AGENTS.md - read and follow it
- There is a `screenshots/` directory with images linked from the README

## Step 0: Familiarise yourself

Before making any changes:

1. Read `AGENTS.md` and follow its instructions
2. Read `plan.md` if it exists
3. Read every `.swift` file in `CountdownTimer/` to understand the current view structure, state management, and how colours/styles are currently applied
4. Read every file in `CountdownTimerTests/` to understand the snapshot tests
5. Note the current window dimensions - the widget should remain compact

## Step 1: Move the bunny image into assets

1. Move `saz-bunny-logo.png` into the Xcode asset catalogue (`CountdownTimer/Assets.xcassets`). Create an image set called `SazBunny` and place the PNG as the universal asset.
2. Delete the original `saz-bunny-logo.png` from the repo root.
3. Update `README.md` to reference the new location if it uses the logo (the logo at the top of the README should continue to display on GitHub - you may need to keep a copy in the repo root or screenshots directory for this purpose, or reference it via the asset path. Use your judgement, but make sure the README still renders the bunny on GitHub).

## Step 2: Create additional image assets

The redesign needs the bunny image at three sizes/variants. For now, use the same `saz-bunny-logo.png` as a placeholder for all three. Add each to the asset catalogue as a separate image set:

- **`SazBunny`** - the full logo (already done in step 1)
- **`SazBunnySmall`** - a small icon version for the countdown screen top-right (placeholder: use the same PNG, it will be displayed at ~28x28pt). Later the owner will replace this with a tighter crop.
- **`SazBunnyPeekExpired`** - the bunny for the expired screen, peeking from the left (placeholder: use the same PNG, displayed at ~76pt wide). Later the owner will replace this with a waving variant.

After creating these, tell the user:

> I've created placeholder image sets `SazBunnySmall` and `SazBunnyPeekExpired` using copies of the main logo. When you have cropped/variant versions, replace the PNGs in:
> - `CountdownTimer/Assets.xcassets/SazBunnySmall.imageset/`
> - `CountdownTimer/Assets.xcassets/SazBunnyPeekExpired.imageset/`

## Step 3: Define the colour system

Create a dedicated `Theme.swift` file (or add to an existing styles/theme file if one exists) with a `SazTheme` enum or struct containing all colour definitions. Use `Color` extensions or static properties. The colours are:

### Backgrounds
| Token | Hex | Usage |
|---|---|---|
| `backgroundBase` | `#F5F0FF` | Main window background (soft lavender) |
| `backgroundSurface` | `#EDE5FF` | Close button background, secondary surfaces |
| `backgroundExpired` | `#FDF2F8` | Window background when timer has expired (soft pink) |

### Text
| Token | Hex | Usage |
|---|---|---|
| `textPrimary` | `#3B0764` | Headings, "When should I finish?" |
| `textDigits` | `#6D28D9` | Countdown digits during active countdown |
| `textDigitsExpired` | `#DB2777` | Countdown digits when expired |
| `textMuted` | `#9CA3AF` | "until HH:MM" label |
| `textActive` | `#0891B2` | "Listening..." status text (cyan/teal) |
| `textError` | `#DB2777` | Error messages (pink) |
| `textExpiredLabel` | `#9F1239` | "Time's up!" label |

### Interactive elements
| Token | Hex | Usage |
|---|---|---|
| `buttonPrimary` | `#7C3AED` | Quit button background (active state) |
| `buttonExpired` | `#DB2777` | Quit button background (expired state) |
| `buttonText` | `#FFFFFF` | Quit button text |
| `closeButton` | `#EDE5FF` | Close (×) button background |
| `closeButtonText` | `#7C3AED` | Close (×) button icon colour |
| `closeButtonExpired` | `#FCE7F3` | Close button background when expired |
| `closeButtonExpiredText` | `#DB2777` | Close button text when expired |

### WCAG accessibility notes
All text/background combinations meet WCAG AA contrast:
- `#3B0764` on `#F5F0FF` = ~13.5:1 (AAA)
- `#6D28D9` on `#F5F0FF` = ~5.8:1 (AA)
- `#0891B2` on `#F5F0FF` = ~4.7:1 (AA)
- `#DB2777` on `#F5F0FF` = ~5.1:1 (AA)
- `#DB2777` on `#FDF2F8` = ~5.4:1 (AA)
- `#FFFFFF` on `#7C3AED` = ~6.5:1 (AA)

## Step 4: Restyle the Ask screen ("When should I finish?")

This is the initial screen shown when the app launches, where the user speaks a time.

### Layout
- **Background**: `backgroundBase` (#F5F0FF)
- **Close button (×)**: top-right, circular, `closeButton` background, `closeButtonText` colour
- **Text**: left-aligned (not centred), pushed to the left ~65% of the window width to leave room for the bunny
- **"When should I finish?"**: `textPrimary`, ~19pt, semibold (`.semibold`), `line-height` 1.25
- **"Listening..."**: `textActive`, ~13pt, appears below the question when speech recognition is active
- **Error text** (e.g. "Invalid time format: 66"): `textError`, ~12pt, appears below "Listening..."
- **Saz-Bunny**: the full `SazBunny` image, positioned on the right side of the window, vertically centred, peeking in from the right edge. The image should overflow/clip at the right edge slightly (about 5-10% cropped) so it looks like the bunny is peeking in, not just placed there. Use `clipped()` on the container. Size the image at roughly 70-76pt wide.
- The window should remain compact - roughly the same width as the current design, with a height of approximately 120pt for the content area.

### Key behaviour
- The bunny is decorative and does not interact with touches/clicks
- The bunny should be behind the text in z-order (lower `zIndex` or placed earlier in a `ZStack`) so if the window is very narrow the text remains readable over the bunny

## Step 5: Restyle the Countdown screen

This is the screen shown while the timer is actively counting down.

### Layout (single horizontal row - very compact)
- **Background**: `backgroundBase` (#F5F0FF)
- **Close button (×)**: top-right, same style as ask screen
- **Left side**: large countdown digits, `textDigits` colour, ~48pt, bold (`.bold`), monospaced or tabular figures (use `.monospacedDigit()` modifier), left-aligned. Format: `MM:SS` or `H:MM:SS`.
- **Right side** (column, right-aligned):
  1. Small bunny icon (`SazBunnySmall` image, ~28x28pt)
  2. Quit button: `buttonPrimary` background, `buttonText` colour, pill shape (large `cornerRadius`), ~13pt text, "Quit"
  3. "until HH:MM" label: `textMuted`, ~12pt
- The overall window height should be approximately 80pt. Very compact - this sits on screen for potentially hours.

### Key behaviour
- Digits must NOT shift position when transitioning to the expired state. The layout is identical, only colours change and the bunny variant swaps.

## Step 6: Restyle the Expired screen

When the countdown reaches 00:00, the screen transforms to alert the user.

### Layout (same structure as countdown, plus bunny)
- **Background**: transitions to `backgroundExpired` (#FDF2F8)
- **Close button**: switches to `closeButtonExpired` / `closeButtonExpiredText`
- **Digits**: change to `textDigitsExpired` (#DB2777) - but STAY IN THE EXACT SAME POSITION. No layout shift.
- **Right column**:
  1. The small bunny icon is hidden (or replaced by empty space to maintain layout)
  2. Quit button: `buttonExpired` background, `buttonText` colour
  3. Label changes to "Time's up!" in `textExpiredLabel` colour, `.semibold`
- **Saz-Bunny (large, peeking from the LEFT)**: the `SazBunnyPeekExpired` image appears on the left side of the window, vertically centred, peeking in from the left edge (mirrored/flipped horizontally compared to the ask screen). Size ~76pt wide. The image should be BEHIND the digits (lower z-index) so the 00:00 text reads clearly over the bunny.
- The window may grow slightly taller to accommodate the bunny (same height as the ask screen, ~120pt), but the digits must remain at the same vertical position they were during countdown. If the window height changes, the digits should stay pinned. Consider whether it's better to keep the window height consistent at ~120pt from the start (during countdown too) or animate the height change - use your judgement for what feels best on macOS.

### Key behaviour
- The transition from countdown to expired should feel gentle, not jarring. Animate the background colour change and the bunny appearance if possible (a short fade-in, ~0.3s).
- The bunny appearing is the primary visual signal that time is up (alongside the colour change and the existing chime sound).

## Step 7: Handle snapshot tests

The project uses `swift-snapshot-testing` for snapshot/screenshot tests.

1. Delete all existing snapshot reference images in `CountdownTimerTests/__Snapshots__/` (the entire directory contents).
2. Run the test suite once: `xcodebuild test -scheme CountdownTimer -destination 'platform=macOS'`. This first run will **record** new reference images and the snapshot tests will fail (this is expected - the library records on first run).
3. Run the test suite a second time. Now the snapshots should pass because reference images exist.
4. If any tests fail on the second run for reasons other than snapshots, investigate and fix.

## Step 8: Update screenshots for the README

The README references screenshots from the `screenshots/` directory. The existing screenshot files should be left in place (do NOT delete them), but note that they will now be out of date.

Tell the user:

> The screenshots in `screenshots/` are now out of date with the new design. After you've built and run the app, take new screenshots of:
> - `screenshots/listening-active.png` - the ask screen in listening state
> - `screenshots/countdown-unfocused.png` - the countdown screen with a timer running
>
> You might also want to add a new `screenshots/expired.png` showing the expired state with Saz peeking in.

## Step 9: Update the CHANGELOG

Add an entry to `CHANGELOG.md` describing the visual redesign. Mention:
- New colour palette derived from Saz-Bunny mascot (purple, teal, pink)
- Bunny mascot now appears on the ask screen (peeking from the right)
- Small bunny icon on the countdown screen
- Large bunny appears on the expired screen (peeking from the left)
- Background shifts from soft lavender to soft pink on expiry
- Moved bunny logo into Xcode asset catalogue

## Design principles to follow throughout

1. **Compact**: This is a floating widget, not a full app window. Every pixel of padding matters. Keep it tight.
2. **Stable layout**: The digits must never jump or shift between states. Pin them.
3. **Soft but bold**: The colours are vivid (saturated purple, bright teal, hot pink) but the backgrounds are gentle pastels. The contrast between bold accents and soft surfaces is the signature.
4. **The bunny has personality**: She peeks in from the right to ask a question, hides while you work, then pops back in from the left when time's up - like she's walked around the back of the window to check on you.
5. **Accessible**: All text must meet WCAG AA contrast ratios. Interactive elements must have sufficient touch/click targets.
6. **macOS native**: Use SwiftUI best practices. Use `Color(red:green:blue:)` initialisers for the custom colours (or hex extensions if one already exists in the project). Use standard macOS window chrome behaviours. Respect the existing window management code (always-on-top, no dock icon, etc.).
7. **Don't break what works**: This redesign is purely visual. Don't change the timer logic, speech recognition, URL scheme handling, time parsing, or any other functional code. Only change view code, colours, layout, and assets.
