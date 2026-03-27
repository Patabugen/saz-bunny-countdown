import SwiftUI

@MainActor
struct CountdownView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @ObservedObject var focusState: PanelFocusState
    @EnvironmentObject var themeManager: ThemeManager
    let onDismiss: () -> Void

    private var t: Theme { themeManager.active }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background
            RoundedRectangle(cornerRadius: t.cornerRadius)
                .fill(t.background)
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

            VStack {
                Spacer()

                // Timer text
                if viewModel.isFinished {
                    Text(viewModel.timeString)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(t.finishedAlert)
                        .shadow(color: t.outerShadowColor, radius: 2, x: 1, y: 2)
                } else {
                    Text(viewModel.timeString)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(t.digitGradient)
                        .shadow(color: t.outerShadowColor, radius: 2, x: 1, y: 2)
                }

                Spacer()

                HStack {
                    if let target = viewModel.targetTimeString {
                        Text("until \(target)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(t.textSecondary)
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Text("Quit")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(t.buttonText)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(t.buttonFill)
                                    .shadow(color: t.outerShadowColor, radius: 3, x: 1, y: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.return, modifiers: [])
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 6) {
                Menu {
                    ThemePickerMenu()
                } label: {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(t.shadow.opacity(0.4))
                }
                .menuStyle(.borderlessButton)
                .fixedSize()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(t.shadow.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            .padding(10)
        }
        .frame(width: WindowConstants.width, height: WindowConstants.height)
        .animation(.easeInOut(duration: 0.15), value: focusState.isFocused)
        .contextMenu { ThemePickerMenu() }
    }
}
