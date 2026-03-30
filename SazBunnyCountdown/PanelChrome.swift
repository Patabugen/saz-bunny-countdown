import SwiftUI

struct PanelChrome<Content: View>: View {
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
            RoundedRectangle(cornerRadius: Colors.cornerRadius)
                .fill(bg)
                .shadow(
                    color: Colors.outerShadowColor,
                    radius: Colors.outerShadowRadius,
                    x: Colors.outerShadowX,
                    y: Colors.outerShadowY
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Colors.cornerRadius)
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
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(fg)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(bgColor))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
            .padding(10)
        }
        .frame(width: WindowConstants.width, height: WindowConstants.height)
    }
}
