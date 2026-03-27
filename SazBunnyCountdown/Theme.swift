import SwiftUI

// MARK: - Theme Data

struct Theme {
    // Base colors (required)
    let background: Color
    let accent: Color
    let accentLight: Color
    let secondary: Color
    let shadow: Color
    let errorText: Color

    // Expired-state colors (default to base colors)
    let backgroundExpired: Color
    let accentExpired: Color

    // Text tokens
    let textDigits: Color
    let textDigitsExpired: Color
    let textMuted: Color
    let textActive: Color
    let textExpiredLabel: Color

    // Interactive tokens
    let buttonPrimary: Color
    let buttonExpired: Color
    let buttonTextColor: Color

    // Close button tokens
    let closeButtonBg: Color
    let closeButtonFg: Color
    let closeButtonExpiredBg: Color
    let closeButtonExpiredFg: Color

    // Shadow geometry
    let outerShadowRadius: CGFloat
    let outerShadowX: CGFloat
    let outerShadowY: CGFloat
    let innerShadowRadius: CGFloat
    let highlightRadius: CGFloat
    let cornerRadius: CGFloat

    // Derived colors
    var textPrimary: Color { shadow }
    var textSecondary: Color { textMuted }
    var finishedAlert: Color { accentExpired }
    var digitGradient: LinearGradient {
        LinearGradient(colors: [accentLight, accent], startPoint: .top, endPoint: .bottom)
    }
    var focusBorder: Color { accent.opacity(0.7) }
    var unfocusBorder: Color { shadow.opacity(0.12) }
    var buttonFill: Color { buttonPrimary }
    var buttonText: Color { buttonTextColor }
    var buttonExpiredFill: Color { buttonExpired }
    var outerShadowColor: Color { shadow.opacity(0.25) }
    var innerShadowColor: Color { shadow.opacity(0.18) }
    var highlightColor: Color { Color.white.opacity(0.45) }
    var expiredBackground: Color { backgroundExpired }

    init(
        background: Color,
        accent: Color,
        accentLight: Color,
        secondary: Color,
        shadow: Color,
        errorText: Color,
        backgroundExpired: Color? = nil,
        accentExpired: Color? = nil,
        textDigits: Color? = nil,
        textDigitsExpired: Color? = nil,
        textMuted: Color? = nil,
        textActive: Color? = nil,
        textExpiredLabel: Color? = nil,
        buttonPrimary: Color? = nil,
        buttonExpired: Color? = nil,
        buttonTextColor: Color? = nil,
        closeButtonBg: Color? = nil,
        closeButtonFg: Color? = nil,
        closeButtonExpiredBg: Color? = nil,
        closeButtonExpiredFg: Color? = nil,
        outerShadowRadius: CGFloat,
        outerShadowX: CGFloat,
        outerShadowY: CGFloat,
        innerShadowRadius: CGFloat,
        highlightRadius: CGFloat,
        cornerRadius: CGFloat
    ) {
        self.background = background
        self.accent = accent
        self.accentLight = accentLight
        self.secondary = secondary
        self.shadow = shadow
        self.errorText = errorText
        self.backgroundExpired = backgroundExpired ?? background
        self.accentExpired = accentExpired ?? accent
        self.textDigits = textDigits ?? accent
        self.textDigitsExpired = textDigitsExpired ?? (accentExpired ?? accent)
        self.textMuted = textMuted ?? shadow.opacity(0.6)
        self.textActive = textActive ?? secondary
        self.textExpiredLabel = textExpiredLabel ?? (accentExpired ?? accent)
        self.buttonPrimary = buttonPrimary ?? accent
        self.buttonExpired = buttonExpired ?? accent
        self.buttonTextColor = buttonTextColor ?? background
        self.closeButtonBg = closeButtonBg ?? background
        self.closeButtonFg = closeButtonFg ?? shadow
        self.closeButtonExpiredBg = closeButtonExpiredBg ?? background
        self.closeButtonExpiredFg = closeButtonExpiredFg ?? shadow
        self.outerShadowRadius = outerShadowRadius
        self.outerShadowX = outerShadowX
        self.outerShadowY = outerShadowY
        self.innerShadowRadius = innerShadowRadius
        self.highlightRadius = highlightRadius
        self.cornerRadius = cornerRadius
    }
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
                background: Color(red: 0.953, green: 0.937, blue: 0.918),
                accent: Color(red: 0.851, green: 0.549, blue: 0.373),
                accentLight: Color(red: 0.949, green: 0.702, blue: 0.541),
                secondary: Color(red: 0.659, green: 0.722, blue: 0.635),
                shadow: Color(red: 0.549, green: 0.416, blue: 0.353),
                errorText: Color(red: 0.78, green: 0.35, blue: 0.30),
                outerShadowRadius: 8, outerShadowX: 3, outerShadowY: 5,
                innerShadowRadius: 4, highlightRadius: 3, cornerRadius: 24
            )
        case .sazBunny:
            return Theme(
                background: Color(red: 0.961, green: 0.941, blue: 1.0),
                accent: Color(red: 0.486, green: 0.228, blue: 0.851),
                accentLight: Color(red: 0.427, green: 0.157, blue: 0.851),
                secondary: Color(red: 0.035, green: 0.569, blue: 0.698),
                shadow: Color(red: 0.231, green: 0.027, blue: 0.392),
                errorText: Color(red: 0.859, green: 0.153, blue: 0.467),
                backgroundExpired: Color(red: 0.992, green: 0.949, blue: 0.973),
                accentExpired: Color(red: 0.859, green: 0.153, blue: 0.467),
                textDigits: Color(red: 0.427, green: 0.157, blue: 0.851),
                textDigitsExpired: Color(red: 0.859, green: 0.153, blue: 0.467),
                textMuted: Color(red: 0.612, green: 0.639, blue: 0.686),
                textActive: Color(red: 0.035, green: 0.569, blue: 0.698),
                textExpiredLabel: Color(red: 0.624, green: 0.071, blue: 0.224),
                buttonPrimary: Color(red: 0.486, green: 0.228, blue: 0.851),
                buttonExpired: Color(red: 0.859, green: 0.153, blue: 0.467),
                buttonTextColor: .white,
                closeButtonBg: Color(red: 0.929, green: 0.898, blue: 1.0),
                closeButtonFg: Color(red: 0.486, green: 0.228, blue: 0.851),
                closeButtonExpiredBg: Color(red: 0.988, green: 0.906, blue: 0.953),
                closeButtonExpiredFg: Color(red: 0.859, green: 0.153, blue: 0.467),
                outerShadowRadius: 6, outerShadowX: 2, outerShadowY: 4,
                innerShadowRadius: 3, highlightRadius: 2, cornerRadius: 20
            )
        }
    }

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
