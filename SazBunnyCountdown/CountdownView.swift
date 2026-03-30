import Accessibility
import SwiftUI

@MainActor
struct CountdownView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @ObservedObject var focusState: PanelFocusState
    let onDismiss: () -> Void
    let onStartNew: () -> Void
    let onRepeat: () -> Void

    var body: some View {
        PanelChrome(
            focusState: focusState,
            backgroundColor: viewModel.isFinished ? Colors.backgroundExpired : nil,
            isExpired: viewModel.isFinished,
            onDismiss: onDismiss
        ) {
            SazBunnyLayout(bunnyImage: viewModel.isFinished ? "SazBunnyExpired" : "SazBunnyCountdown") {
                VStack(spacing: 4) {
                    Text(viewModel.timeString)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(viewModel.isFinished ? Colors.textDigitsExpired : Colors.textDigits)

                    HStack(spacing: 8) {
                        Button(action: onDismiss) {
                            Text("Quit")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(Colors.buttonText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(viewModel.isFinished ? Colors.buttonExpiredFill : Colors.buttonFill)
                                )
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(.return, modifiers: [])

                        if viewModel.isFinished {
                            Button(action: onStartNew) {
                                Text("Start New")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Colors.buttonText)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(Colors.accent)
                                    )
                            }
                            .buttonStyle(.plain)
                        } else if let target = viewModel.targetTimeString {
                            Text("until \(target)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Colors.textSecondary)
                        }
                    }

                    if viewModel.isFinished, let repeatTime = viewModel.repeatTargetTimeString {
                        Button(action: onRepeat) {
                            Text("Repeat \u{2013} countdown to \(repeatTime)")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(Colors.buttonText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Colors.buttonExpiredFill.opacity(0.7))
                                )
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    }
                }
                .padding(.leading, 20)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.isFinished ? "Timer finished" : "Countdown timer")
        .accessibilityValue(viewModel.timeString)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isFinished)
        .animation(.easeInOut(duration: 0.15), value: focusState.isFocused)
        .onChange(of: viewModel.isFinished) { finished in
            if finished {
                if #available(macOS 14.0, *) {
                    AccessibilityNotification.Announcement("Timer finished").post()
                } else {
                    NSAccessibility.post(
                        element: NSApp as Any,
                        notification: .announcementRequested,
                        userInfo: [
                            .announcement: "Timer finished" as NSString,
                            .priority: NSAccessibilityPriorityLevel.high.rawValue
                        ]
                    )
                }
            }
        }
    }
}
