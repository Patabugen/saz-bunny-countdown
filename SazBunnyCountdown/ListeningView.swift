import SwiftUI

@MainActor
struct ListeningView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @ObservedObject var focusState: PanelFocusState
    var parseError: String?
    let onDismiss: () -> Void

    private var bunnyImage: String {
        if speechRecognizer.error != nil || parseError != nil {
            return "SazBunnyError"
        }
        return "SazBunnyListening"
    }

    var body: some View {
        PanelChrome(focusState: focusState, onDismiss: onDismiss) {
            SazBunnyLayout(bunnyImage: bunnyImage) {
                VStack(spacing: 4) {
                    if let error = speechRecognizer.error {
                        Text(error)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Colors.errorText)
                    } else if speechRecognizer.transcript.isEmpty {
                        Text("When should\nI finish?")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Colors.textPrimary)
                    } else {
                        Text(speechRecognizer.transcript)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Colors.textPrimary)
                    }

                    if speechRecognizer.isListening && speechRecognizer.error == nil {
                        Text("Listening...")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Colors.textActive)
                    }

                    if let parseError = parseError {
                        Text(parseError)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Colors.errorText)
                    }
                }
                .padding(.leading, 20)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(speechRecognizer.isListening ? "Listening for time" : "Timer setup")
        .accessibilityValue(speechRecognizer.transcript.isEmpty ? "Waiting for input" : speechRecognizer.transcript)
    }
}
