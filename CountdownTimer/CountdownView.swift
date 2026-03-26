import SwiftUI

@MainActor
struct CountdownView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @ObservedObject var focusState: PanelFocusState
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background
            RoundedRectangle(cornerRadius: ClayTheme.cornerRadius)
                .fill(ClayTheme.background)
                .shadow(
                    color: ClayTheme.outerShadowColor,
                    radius: ClayTheme.outerShadowRadius,
                    x: ClayTheme.outerShadowX,
                    y: ClayTheme.outerShadowY
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ClayTheme.cornerRadius)
                        .strokeBorder(
                            focusState.isFocused ? ClayTheme.focusBorder : ClayTheme.unfocusBorder,
                            lineWidth: focusState.isFocused ? 2.5 : 1
                        )
                )

            VStack(spacing: 6) {
                // Digit pill
                ZStack {
                    RoundedRectangle(cornerRadius: ClayTheme.digitPillCornerRadius)
                        .fill(ClayTheme.background)
                        // Inner shadow (bottom-right)
                        .overlay(
                            RoundedRectangle(cornerRadius: ClayTheme.digitPillCornerRadius)
                                .stroke(ClayTheme.innerShadowColor, lineWidth: 2)
                                .blur(radius: ClayTheme.innerShadowRadius)
                                .offset(x: 2, y: 2)
                                .mask(
                                    RoundedRectangle(cornerRadius: ClayTheme.digitPillCornerRadius)
                                        .fill(LinearGradient(
                                            colors: [.black, .clear],
                                            startPoint: .bottomTrailing,
                                            endPoint: .topLeading
                                        ))
                                )
                        )
                        // Top-left highlight
                        .overlay(
                            RoundedRectangle(cornerRadius: ClayTheme.digitPillCornerRadius)
                                .stroke(ClayTheme.highlightColor, lineWidth: 2)
                                .blur(radius: ClayTheme.highlightRadius)
                                .offset(x: -1, y: -1)
                                .mask(
                                    RoundedRectangle(cornerRadius: ClayTheme.digitPillCornerRadius)
                                        .fill(LinearGradient(
                                            colors: [.black, .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                )
                        )
                        .shadow(color: ClayTheme.outerShadowColor, radius: 4, x: 2, y: 3)

                    // Timer text
                    if viewModel.isFinished {
                        Text(viewModel.timeString)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(ClayTheme.finishedAlert)
                            .shadow(color: ClayTheme.outerShadowColor, radius: 2, x: 1, y: 2)
                    } else {
                        Text(viewModel.timeString)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(ClayTheme.digitGradient)
                            .shadow(color: ClayTheme.outerShadowColor, radius: 2, x: 1, y: 2)
                    }
                }
                .padding(.horizontal, ClayTheme.digitPillPaddingH)
                .padding(.vertical, ClayTheme.digitPillPaddingV)
                .fixedSize(horizontal: false, vertical: true)

                if let target = viewModel.targetTimeString {
                    Text("until \(target)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(ClayTheme.textSecondary)
                }

                Button(action: onDismiss) {
                    Text("Quit")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(ClayTheme.buttonText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(ClayTheme.buttonFill)
                                .shadow(color: ClayTheme.outerShadowColor, radius: 3, x: 1, y: 2)
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return, modifiers: [])
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ClayTheme.shadow.opacity(0.4))
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .frame(width: ClayTheme.windowWidth, height: ClayTheme.windowHeight)
        .animation(.easeInOut(duration: 0.15), value: focusState.isFocused)
    }
}
