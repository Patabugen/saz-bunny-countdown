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

            VStack {
                Spacer()

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

                Spacer()

                HStack {
                    if let target = viewModel.targetTimeString {
                        Text("until \(target)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(ClayTheme.textSecondary)
                    }

                    Spacer()

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
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
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
