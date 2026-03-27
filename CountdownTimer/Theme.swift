import SwiftUI

// MARK: - Theme Data

struct Theme {
    let background: Color
    let accent: Color
    let accentLight: Color
    let secondary: Color
    let shadow: Color
    let errorText: Color

    // Derived colors
    var textPrimary: Color { shadow }
    var textSecondary: Color { shadow.opacity(0.6) }
    var finishedAlert: Color { accent }
    var digitGradient: LinearGradient {
        LinearGradient(colors: [accentLight, accent], startPoint: .top, endPoint: .bottom)
    }
    var focusBorder: Color { accent.opacity(0.7) }
    var unfocusBorder: Color { shadow.opacity(0.12) }
    var buttonFill: Color { accent }
    var buttonText: Color { background }
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
                outerShadowRadius: 8, outerShadowX: 3, outerShadowY: 5,
                innerShadowRadius: 4, highlightRadius: 3, cornerRadius: 24
            )
        case .sazBunny:
            // Placeholder — same as Clay until custom theme is defined
            return ThemeStyle.clay.theme
        }
    }
}

// MARK: - Theme Manager

@MainActor
class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") private var stored: String = ThemeStyle.clay.rawValue

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
