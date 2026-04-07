import Accessibility
import SwiftUI

@MainActor
struct CountdownView: View {
    @EnvironmentObject var sizePreset: SizePreset
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
                VStack(spacing: sizePreset.scaled(4)) {
                    Text(viewModel.timeString)
                        .font(sizePreset.font(48, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(viewModel.isFinished ? Colors.textDigitsExpired : Colors.textDigits)

                    HStack(spacing: sizePreset.scaled(8)) {
                        Button(action: onDismiss) {
                            Text("Quit")
                                .font(sizePreset.font(13, weight: .semibold))
                                .foregroundStyle(Colors.buttonText)
                                .padding(.horizontal, sizePreset.scaled(16))
                                .padding(.vertical, sizePreset.scaled(5))
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
                                    .font(sizePreset.font(13, weight: .semibold))
                                    .foregroundStyle(Colors.buttonText)
                                    .padding(.horizontal, sizePreset.scaled(16))
                                    .padding(.vertical, sizePreset.scaled(5))
                                    .background(
                                        Capsule()
                                            .fill(Colors.accent)
                                    )
                            }
                            .buttonStyle(.plain)
                        } else if let target = viewModel.targetTimeString {
                            Text("until \(target)")
                                .font(sizePreset.font(12, weight: .medium))
                                .foregroundStyle(Colors.textSecondary)
                        }
                    }

                    if viewModel.isFinished, let repeatTime = viewModel.repeatTargetTimeString {
                        Button(action: onRepeat) {
                            Text("Repeat \u{2013} countdown to \(repeatTime)")
                                .font(sizePreset.font(11, weight: .medium))
                                .foregroundStyle(Colors.buttonText)
                                .padding(.horizontal, sizePreset.scaled(12))
                                .padding(.vertical, sizePreset.scaled(3))
                                .background(
                                    Capsule()
                                        .fill(Colors.buttonExpiredFill.opacity(0.7))
                                )
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    }
                }
                .padding(.leading, sizePreset.scaled(20))
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
