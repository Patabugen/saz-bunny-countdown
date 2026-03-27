import SwiftUI

@MainActor
struct ListeningView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @ObservedObject var focusState: PanelFocusState
    @EnvironmentObject var themeManager: ThemeManager
    var parseError: String?
    let onDismiss: () -> Void

    private var t: Theme { themeManager.active }
    private var isSazBunny: Bool { themeManager.activeStyle.usesBunnyImagery }

    var body: some View {
        PanelChrome(focusState: focusState, onDismiss: onDismiss) {
            if isSazBunny {
                sazBunnyContent
            } else {
                classicContent
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(speechRecognizer.isListening ? "Listening for time" : "Timer setup")
        .accessibilityValue(speechRecognizer.transcript.isEmpty ? "Waiting for input" : speechRecognizer.transcript)
    }

    // MARK: - Saz Bunny Layout

    private var sazBunnyImage: String {
        if speechRecognizer.error != nil || parseError != nil {
            return "SazBunnyError"
        }
        return "SazBunnyListening"
    }

    private var sazBunnyContent: some View {
        SazBunnyLayout(bunnyImage: sazBunnyImage) {
            VStack(spacing: 4) {
                if let error = speechRecognizer.error {
                    Text(error)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(t.errorText)
                } else if speechRecognizer.transcript.isEmpty {
                    Text("When should\nI finish?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(t.textPrimary)
                } else {
                    Text(speechRecognizer.transcript)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(t.textPrimary)
                }

                if speechRecognizer.isListening && speechRecognizer.error == nil {
                    Text("Listening...")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(t.textActive ?? t.secondary)
                }

                if let parseError = parseError {
                    Text(parseError)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(t.errorText)
                }
            }
            .padding(.leading, 20)
        }
    }

    // MARK: - Classic (Clay) Layout

    private var classicContent: some View {
        VStack(spacing: 6) {
            if let error = speechRecognizer.error {
                Text(error)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(t.errorText)
                    .multilineTextAlignment(.center)
            } else if speechRecognizer.transcript.isEmpty {
                Text("When should I finish?")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(t.textPrimary)

                if speechRecognizer.isListening {
                    Text("Listening...")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(t.secondary)
                }
            } else {
                Text(speechRecognizer.transcript)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(t.textPrimary)
            }

            if let parseError = parseError {
                Text(parseError)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(t.errorText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }
}
