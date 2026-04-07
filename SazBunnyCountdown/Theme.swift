import SwiftUI

// MARK: - Color Palette

enum Colors {
    // Base
    static let background = Color(red: 0.961, green: 0.941, blue: 1.0)
    static let accent = Color(red: 0.486, green: 0.228, blue: 0.851)
    static let accentLight = Color(red: 0.427, green: 0.157, blue: 0.851)
    static let shadow = Color(red: 0.231, green: 0.027, blue: 0.392)
    static let errorText = Color(red: 0.859, green: 0.153, blue: 0.467)

    // Expired state
    static let backgroundExpired = Color(red: 0.992, green: 0.949, blue: 0.973)
    static let accentExpired = Color(red: 0.859, green: 0.153, blue: 0.467)

    // Text
    static let textDigits = Color(red: 0.427, green: 0.157, blue: 0.851)
    static let textDigitsExpired = Color(red: 0.859, green: 0.153, blue: 0.467)
    static let textPrimary = shadow
    static let textSecondary = Color(red: 0.612, green: 0.639, blue: 0.686)
    static let textActive = Color(red: 0.035, green: 0.569, blue: 0.698)

    // Buttons
    static let buttonFill = accent
    static let buttonExpiredFill = Color(red: 0.859, green: 0.153, blue: 0.467)
    static let buttonText = Color.white

    // Close button
    static let closeButtonBg = Color(red: 0.929, green: 0.898, blue: 1.0)
    static let closeButtonFg = Color(red: 0.486, green: 0.228, blue: 0.851)
    static let closeButtonExpiredBg = Color(red: 0.988, green: 0.906, blue: 0.953)
    static let closeButtonExpiredFg = Color(red: 0.859, green: 0.153, blue: 0.467)

    // Borders
    static let focusBorder = accent.opacity(0.7)
    static let unfocusBorder = shadow.opacity(0.12)

    // Shadows
    static let outerShadowColor = shadow.opacity(0.25)
    static let outerShadowRadius: CGFloat = 6
    static let outerShadowX: CGFloat = 2
    static let outerShadowY: CGFloat = 4

    // Geometry
    static let baseCornerRadius: CGFloat = 20
}