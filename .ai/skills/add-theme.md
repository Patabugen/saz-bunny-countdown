# Add a New Theme

## When to use
When the user asks to add, create, or define a new visual theme/style for the countdown timer.

## Steps

### 1. Define the theme in `CountdownTimer/Theme.swift`

Add a new case to the `ThemeStyle` enum:

```swift
enum ThemeStyle: String, CaseIterable, Identifiable {
    case clay = "Clay"
    case myNewTheme = "My New Theme"  // add case here
    ...
}
```

Then add a corresponding branch in the `theme` computed property with a `Theme(...)` initializer:

```swift
case .myNewTheme:
    return Theme(
        background: Color(...),      // main window background
        accent: Color(...),          // primary accent (buttons, focus border, digit gradient bottom, finished alert)
        accentLight: Color(...),     // lighter accent (digit gradient top)
        secondary: Color(...),       // secondary UI elements (e.g. "Listening..." text)
        shadow: Color(...),          // text color base + shadow color base
        errorText: Color(...),       // error message color
        outerShadowRadius: 8,       // outer shadow blur radius
        outerShadowX: 3,            // outer shadow x offset
        outerShadowY: 5,            // outer shadow y offset
        innerShadowRadius: 4,       // inner shadow blur radius
        highlightRadius: 3,         // highlight blur radius
        cornerRadius: 24            // window corner radius
    )
```

**Color roles reference:**
- `background` → window fill, button text color
- `accent` → button fill, focus border (at 0.7 opacity), finished alert color, digit gradient bottom
- `accentLight` → digit gradient top
- `secondary` → "Listening..." indicator text
- `shadow` → primary text color, secondary text (at 0.6 opacity), outer shadow (at 0.25 opacity), inner shadow (at 0.18 opacity), unfocused border (at 0.12 opacity), close/gear icon tint (at 0.4 opacity)
- `errorText` → error messages

**No other files need to be modified.** The views, menus, and persistence all adapt automatically via the `ThemeStyle.allCases` enumeration.

### 2. Add a snapshot test

In `CountdownTimerTests/SnapshotTests.swift`, add a test for the new theme:

```swift
@Test("Countdown view with <themeName> theme")
func countdown<ThemeName>() {
    let viewModel = CountdownViewModel()
    let focusState = PanelFocusState()
    focusState.isFocused = true
    let themeManager = ThemeManager()
    themeManager.activeStyle = .<themeCaseeName>

    let view = CountdownView(viewModel: viewModel, focusState: focusState) {}
        .environmentObject(themeManager)
    let hostingView = NSHostingView(rootView: view)
    hostingView.frame = NSRect(x: 0, y: 0, width: WindowConstants.width, height: WindowConstants.height)
    assertSnapshot(of: hostingView, as: .image)
}
```

### 3. Build and test

```bash
# Build
xcodebuild -project CountdownTimer.xcodeproj -scheme CountdownTimer -destination 'platform=macOS' build

# First test run records the new snapshot (will fail — expected)
xcodebuild -project CountdownTimer.xcodeproj -scheme CountdownTimer -destination 'platform=macOS' test

# Second test run verifies all snapshots match
xcodebuild -project CountdownTimer.xcodeproj -scheme CountdownTimer -destination 'platform=macOS' test
```

All tests must pass on the second run with zero failures.

### 4. Update README screenshots (if needed)

If this theme replaces the default, copy the new snapshots to `screenshots/`:

```bash
cp CountdownTimerTests/__Snapshots__/SnapshotTests/<snapshotName>.1.png screenshots/<target>.png
```

The README references: `screenshots/listening-active.png` and `screenshots/countdown-unfocused.png`.
