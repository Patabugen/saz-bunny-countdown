import SwiftUI

// MARK: - Theme Data

struct Theme {
    let background: Color
    let accent: Color
    let accentLight: Color
    let secondary: Color
    let shadow: Color
    let errorText: Color

    // Expired-state overrides (default to normal values for themes that don't differentiate)
    let backgroundExpired: Color?
    let accentExpired: Color?
    let errorTextExpired: Color?

    // Saz-specific tokens (nil = theme doesn't use them)
    let textDigits: Color?
    let textDigitsExpired: Color?
    let textMuted: Color?
    let textActive: Color?
    let textExpiredLabel: Color?
    let buttonPrimary: Color?
    let buttonExpired: Color?
    let buttonTextColor: Color?
    let closeButtonBg: Color?
    let closeButtonFg: Color?
    let closeButtonExpiredBg: Color?
    let closeButtonExpiredFg: Color?

    // Derived colors
    var textPrimary: Color { shadow }
    var textSecondary: Color { textMuted ?? shadow.opacity(0.6) }
    var finishedAlert: Color { accentExpired ?? accent }
    var digitGradient: LinearGradient {
        LinearGradient(colors: [accentLight, accent], startPoint: .top, endPoint: .bottom)
    }
    var focusBorder: Color { accent.opacity(0.7) }
    var unfocusBorder: Color { shadow.opacity(0.12) }
    var buttonFill: Color { buttonPrimary ?? accent }
    var buttonText: Color { buttonTextColor ?? background }
    var buttonExpiredFill: Color { buttonExpired ?? accent }
    var outerShadowColor: Color { shadow.opacity(0.25) }
    var innerShadowColor: Color { shadow.opacity(0.18) }
    var highlightColor: Color { Color.white.opacity(0.45) }

    // Shadow geometry
    let outerShadowRadius: CGFloat
    let outerShadowX: CGFloat
    let outerShadowY: CGFloat
    let innerShadowRadius: CGFloat
    let highlightRadius: CGFloat
    let cornerRadius: CGFloat

    // Convenience for expired background
    var expiredBackground: Color { backgroundExpired ?? background }
}

// MARK: - Window Dimensions (constant across themes)

enum WindowConstants {
    static let width: CGFloat = 320
    static let height: CGFloat = 160
}

// MARK: - Theme Catalog

enum ThemeStyle: String, CaseIterable, Identifiable {
    case clay = "Clay"
    case sazBunny = "Saz Bunny"

    var id: String { rawValue }

    var theme: Theme {
        switch self {
        case .clay:
            return Theme(
                background: Color(red: 0.953, green: 0.937, blue: 0.918),  // #F3EFEA
                accent: Color(red: 0.851, green: 0.549, blue: 0.373),      // #D98C5F
                accentLight: Color(red: 0.949, green: 0.702, blue: 0.541), // #F2B38A
                secondary: Color(red: 0.659, green: 0.722, blue: 0.635),   // #A8B8A2
                shadow: Color(red: 0.549, green: 0.416, blue: 0.353),      // #8C6A5A
                errorText: Color(red: 0.78, green: 0.35, blue: 0.30),
                backgroundExpired: nil,
                accentExpired: nil,
                errorTextExpired: nil,
                textDigits: nil,
                textDigitsExpired: nil,
                textMuted: nil,
                textActive: nil,
                textExpiredLabel: nil,
                buttonPrimary: nil,
                buttonExpired: nil,
                buttonTextColor: nil,
                closeButtonBg: nil,
                closeButtonFg: nil,
                closeButtonExpiredBg: nil,
                closeButtonExpiredFg: nil,
                outerShadowRadius: 8, outerShadowX: 3, outerShadowY: 5,
                innerShadowRadius: 4, highlightRadius: 3, cornerRadius: 24
            )
        case .sazBunny:
            return Theme(
                // Backgrounds
                background: Color(red: 0.961, green: 0.941, blue: 1.0),        // #F5F0FF backgroundBase
                accent: Color(red: 0.486, green: 0.228, blue: 0.851),          // #7C3AED buttonPrimary
                accentLight: Color(red: 0.427, green: 0.157, blue: 0.851),     // #6D28D9 textDigits
                secondary: Color(red: 0.035, green: 0.569, blue: 0.698),       // #0891B2 textActive
                shadow: Color(red: 0.231, green: 0.027, blue: 0.392),          // #3B0764 textPrimary
                errorText: Color(red: 0.859, green: 0.153, blue: 0.467),       // #DB2777 textError

                // Expired backgrounds
                backgroundExpired: Color(red: 0.992, green: 0.949, blue: 0.973),  // #FDF2F8
                accentExpired: Color(red: 0.859, green: 0.153, blue: 0.467),      // #DB2777
                errorTextExpired: Color(red: 0.859, green: 0.153, blue: 0.467),   // #DB2777

                // Text tokens
                textDigits: Color(red: 0.427, green: 0.157, blue: 0.851),         // #6D28D9
                textDigitsExpired: Color(red: 0.859, green: 0.153, blue: 0.467),  // #DB2777
                textMuted: Color(red: 0.612, green: 0.639, blue: 0.686),          // #9CA3AF
                textActive: Color(red: 0.035, green: 0.569, blue: 0.698),         // #0891B2
                textExpiredLabel: Color(red: 0.624, green: 0.071, blue: 0.224),   // #9F1239

                // Interactive
                buttonPrimary: Color(red: 0.486, green: 0.228, blue: 0.851),      // #7C3AED
                buttonExpired: Color(red: 0.859, green: 0.153, blue: 0.467),      // #DB2777
                buttonTextColor: .white,                                            // #FFFFFF

                // Close button
                closeButtonBg: Color(red: 0.929, green: 0.898, blue: 1.0),        // #EDE5FF
                closeButtonFg: Color(red: 0.486, green: 0.228, blue: 0.851),      // #7C3AED
                closeButtonExpiredBg: Color(red: 0.988, green: 0.906, blue: 0.953), // #FCE7F3
                closeButtonExpiredFg: Color(red: 0.859, green: 0.153, blue: 0.467), // #DB2777

                outerShadowRadius: 6, outerShadowX: 2, outerShadowY: 4,
                innerShadowRadius: 3, highlightRadius: 2, cornerRadius: 20
            )
        }
    }

    /// Whether this theme uses the Saz-Bunny mascot imagery
    var usesBunnyImagery: Bool {
        self == .sazBunny
    }
}

// MARK: - Theme Manager

@MainActor
class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") private var stored: String = ThemeStyle.sazBunny.rawValue

    var activeStyle: ThemeStyle {
        get { ThemeStyle(rawValue: stored) ?? .clay }
        set { stored = newValue.rawValue; objectWillChange.send() }
    }

    var active: Theme { activeStyle.theme }
}

// MARK: - Theme Picker Menu

struct ThemePickerMenu: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ForEach(ThemeStyle.allCases) { style in
            Button {
                themeManager.activeStyle = style
            } label: {
                if themeManager.activeStyle == style {
                    Label(style.rawValue, systemImage: "checkmark")
                } else {
                    Text(style.rawValue)
                }
            }
        }
    }
}
