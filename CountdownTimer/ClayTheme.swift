import SwiftUI

struct ClayTheme {
    // MARK: - Colors
    static let background    = Color(red: 0.953, green: 0.937, blue: 0.918) // #F3EFEA
    static let clayOrange    = Color(red: 0.851, green: 0.549, blue: 0.373) // #D98C5F
    static let clayLight     = Color(red: 0.949, green: 0.702, blue: 0.541) // #F2B38A
    static let sage          = Color(red: 0.659, green: 0.722, blue: 0.635) // #A8B8A2
    static let shadow        = Color(red: 0.549, green: 0.416, blue: 0.353) // #8C6A5A

    // MARK: - Derived colors
    static let textPrimary   = shadow
    static let textSecondary = shadow.opacity(0.6)
    static let finishedAlert = clayOrange
    static let errorText     = Color(red: 0.78, green: 0.35, blue: 0.30)

    // MARK: - Digit gradient (top-lighter to bottom-darker)
    static let digitGradient = LinearGradient(
        colors: [clayLight, clayOrange],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Focus border
    static let focusBorder   = clayOrange.opacity(0.7)
    static let unfocusBorder = shadow.opacity(0.12)

    // MARK: - Button
    static let buttonFill    = clayOrange
    static let buttonText    = background

    // MARK: - Dimensions
    static let windowWidth:  CGFloat = 320
    static let windowHeight: CGFloat = 160
    static let cornerRadius: CGFloat = 24
    static let digitPillCornerRadius: CGFloat = 16
    static let digitPillPaddingH: CGFloat = 20
    static let digitPillPaddingV: CGFloat = 10

    // MARK: - Shadows (light source: top-left)
    static let outerShadowColor   = shadow.opacity(0.25)
    static let outerShadowRadius: CGFloat = 8
    static let outerShadowX: CGFloat = 3
    static let outerShadowY: CGFloat = 5

    static let innerShadowColor   = shadow.opacity(0.18)
    static let innerShadowRadius: CGFloat = 4

    static let highlightColor     = Color.white.opacity(0.45)
    static let highlightRadius: CGFloat = 3
}
