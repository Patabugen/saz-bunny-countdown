import SwiftUI

@MainActor
struct CountdownView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @ObservedObject var focusState: PanelFocusState
    @EnvironmentObject var themeManager: ThemeManager
    let onDismiss: () -> Void
    let onStartNew: () -> Void

    private var t: Theme { themeManager.active }
    private var isSazBunny: Bool { themeManager.activeStyle.usesBunnyImagery }

    var body: some View {
        PanelChrome(
            focusState: focusState,
            backgroundColor: isSazBunny && viewModel.isFinished ? t.expiredBackground : nil,
            isExpired: viewModel.isFinished,
            onDismiss: onDismiss
        ) {
            if isSazBunny {
                sazBunnyContent
            } else {
                classicContent
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isFinished)
        .animation(.easeInOut(duration: 0.15), value: focusState.isFocused)
    }

    // MARK: - Saz Bunny Layout

    private var sazBunnyContent: some View {
        SazBunnyLayout(bunnyImage: viewModel.isFinished ? "SazBunnyExpired" : "SazBunnyCountdown") {
            VStack(spacing: 4) {
                Text(viewModel.timeString)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(sazDigitColor)

                HStack(spacing: 8) {
                    Button(action: onDismiss) {
                        Text("Quit")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(t.buttonText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(viewModel.isFinished ? t.buttonExpiredFill : t.buttonFill)
                            )
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.return, modifiers: [])

                    if viewModel.isFinished {
                        Button(action: onStartNew) {
                            Text("Start New")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(t.buttonText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(t.accent)
                                )
                        }
                        .buttonStyle(.plain)
                    } else if let target = viewModel.targetTimeString {
                        Text("until \(target)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(t.textSecondary)
                    }
                }
            }
            .padding(.leading, 20)
        }
    }

    private var sazDigitColor: Color {
        if viewModel.isFinished {
            return t.textDigitsExpired ?? t.finishedAlert
        }
        return t.textDigits ?? t.accent
    }

    // MARK: - Classic (Clay) Layout

    private var classicContent: some View {
        VStack {
            Spacer()

            if viewModel.isFinished {
                Text(viewModel.timeString)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(t.finishedAlert)
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
                if viewModel.isFinished {
                    Button(action: onStartNew) {
                        Text("Start New")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(t.buttonText)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(t.buttonFill)
                                    .shadow(color: t.outerShadowColor, radius: 3, x: 1, y: 2)
                            )
                    }
                    .buttonStyle(.plain)
                } else if let target = viewModel.targetTimeString {
                    Text("until \(target)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(t.textSecondary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Text("Quit")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(t.buttonText)
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
    }
}
