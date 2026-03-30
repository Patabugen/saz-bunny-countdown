import SwiftUI

@MainActor
struct CountdownView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @ObservedObject var focusState: PanelFocusState
    @EnvironmentObject var themeManager: ThemeManager
    let onDismiss: () -> Void
    let onStartNew: () -> Void
    let onRepeat: () -> Void

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
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.isFinished ? "Timer finished" : "Countdown timer")
        .accessibilityValue(viewModel.timeString)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isFinished)
        .animation(.easeInOut(duration: 0.15), value: focusState.isFocused)
        .onChange(of: viewModel.isFinished) { finished in
            if finished {
                NSAccessibility.post(
                    element: NSApp as Any,
                    notification: .announcementRequested,
                    userInfo: [
                        NSAccessibility.NotificationUserInfoKey.announcement: "Timer finished" as NSString,
                        NSAccessibility.NotificationUserInfoKey.priority: NSAccessibilityPriorityLevel.high.rawValue
                    ]
                )
            }
        }
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

                if viewModel.isFinished, let repeatTime = viewModel.repeatTargetTimeString {
                    Button(action: onRepeat) {
                        Text("Repeat \u{2013} countdown to \(repeatTime)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(t.buttonText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(t.buttonExpiredFill.opacity(0.7))
                            )
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(.leading, 20)
        }
    }

    private var sazDigitColor: Color {
        viewModel.isFinished ? t.textDigitsExpired : t.textDigits
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

            VStack(spacing: 6) {
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

                if viewModel.isFinished, let repeatTime = viewModel.repeatTargetTimeString {
                    Button(action: onRepeat) {
                        Text("Repeat \u{2013} countdown to \(repeatTime)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(t.buttonText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(t.buttonFill)
                                    .shadow(color: t.outerShadowColor, radius: 3, x: 1, y: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
