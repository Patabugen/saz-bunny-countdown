import SwiftUI

struct PanelChrome<Content: View>: View {
    @EnvironmentObject var sizePreset: SizePreset
    @ObservedObject var focusState: PanelFocusState
    let backgroundColor: Color?
    let isExpired: Bool
    let onDismiss: () -> Void
    @ViewBuilder let content: Content

    init(
        focusState: PanelFocusState,
        backgroundColor: Color? = nil,
        isExpired: Bool = false,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.focusState = focusState
        self.backgroundColor = backgroundColor
        self.isExpired = isExpired
        self.onDismiss = onDismiss
        self.content = content()
    }

    private var bg: Color { backgroundColor ?? Colors.background }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: sizePreset.cornerRadius)
                .fill(bg)
                .shadow(
                    color: Colors.outerShadowColor,
                    radius: Colors.outerShadowRadius,
                    x: Colors.outerShadowX,
                    y: Colors.outerShadowY
                )
                .overlay(
                    RoundedRectangle(cornerRadius: sizePreset.cornerRadius)
                        .strokeBorder(
                            focusState.isFocused ? Colors.focusBorder : Colors.unfocusBorder,
                            lineWidth: focusState.isFocused ? 2.5 : 1
                        )
                )

            content

            // Top-right close button
            Button(action: onDismiss) {
                let fg = isExpired ? Colors.closeButtonExpiredFg : Colors.closeButtonFg
                let bgColor = isExpired ? Colors.closeButtonExpiredBg : Colors.closeButtonBg
                Image(systemName: "xmark")
                    .font(.system(size: sizePreset.scaled(10), weight: .bold))
                    .foregroundStyle(fg)
                    .frame(width: sizePreset.scaled(22), height: sizePreset.scaled(22))
                    .background(Circle().fill(bgColor))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
            .padding(sizePreset.scaled(10))

        }
        .frame(width: sizePreset.windowWidth, height: sizePreset.windowHeight)
        .overlay(alignment: .bottomTrailing) {
            ResizeGrip(scale: sizePreset.scale, isExpired: isExpired)
                .padding(sizePreset.scaled(6))
                .allowsHitTesting(false)
        }
    }
}

/// A diagonal grip indicator for the resize handle zone.
private struct ResizeGrip: View {
    let scale: CGFloat
    let isExpired: Bool

    var body: some View {
        let color = isExpired ? Colors.accentExpired : Colors.accent
        Image(systemName: "arrow.down.right")
            .font(.system(size: 10 * scale, weight: .semibold))
            .foregroundStyle(color.opacity(0.6))
            .frame(width: 20 * scale, height: 20 * scale)
    }
}
