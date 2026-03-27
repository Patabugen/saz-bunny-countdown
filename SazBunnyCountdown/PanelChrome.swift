import SwiftUI

struct PanelChrome<Content: View>: View {
    @ObservedObject var focusState: PanelFocusState
    @EnvironmentObject var themeManager: ThemeManager
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

    private var t: Theme { themeManager.active }
    private var isSazBunny: Bool { themeManager.activeStyle.usesBunnyImagery }
    private var bg: Color { backgroundColor ?? t.background }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: t.cornerRadius)
                .fill(bg)
                .shadow(
                    color: t.outerShadowColor,
                    radius: t.outerShadowRadius,
                    x: t.outerShadowX,
                    y: t.outerShadowY
                )
                .overlay(
                    RoundedRectangle(cornerRadius: t.cornerRadius)
                        .strokeBorder(
                            focusState.isFocused ? t.focusBorder : t.unfocusBorder,
                            lineWidth: focusState.isFocused ? 2.5 : 1
                        )
                )

            content

            // Top-right controls
            HStack(spacing: 6) {
                Menu {
                    ThemePickerMenu()
                } label: {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(t.shadow.opacity(0.4))
                }
                .menuStyle(.borderlessButton)
                .fixedSize()

                closeButton
            }
            .padding(10)
        }
        .frame(width: WindowConstants.width, height: WindowConstants.height)
        .contextMenu { ThemePickerMenu() }
    }

    @ViewBuilder
    private var closeButton: some View {
        if isSazBunny {
            let fg = isExpired ? (t.closeButtonExpiredFg ?? t.shadow) : (t.closeButtonFg ?? t.shadow)
            let bgColor = isExpired ? (t.closeButtonExpiredBg ?? t.background) : (t.closeButtonBg ?? t.background)
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(fg)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(bgColor))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        } else {
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(t.shadow.opacity(0.4))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
    }
}
