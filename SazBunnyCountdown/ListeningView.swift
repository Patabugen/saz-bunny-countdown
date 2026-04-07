import SwiftUI

@MainActor
struct ListeningView: View {
    @EnvironmentObject var sizePreset: SizePreset
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
                VStack(spacing: sizePreset.scaled(4)) {
                    if let error = speechRecognizer.error {
                        Text(error)
                            .font(sizePreset.font(13, weight: .medium))
                            .foregroundStyle(Colors.errorText)
                    } else if speechRecognizer.transcript.isEmpty {
                        Text("When should\nI finish?")
                            .font(sizePreset.font(24, weight: .bold))
                            .foregroundStyle(Colors.textPrimary)
                    } else {
                        Text(speechRecognizer.transcript)
                            .font(sizePreset.font(18, weight: .semibold))
                            .foregroundStyle(Colors.textPrimary)
                    }

                    if speechRecognizer.isListening && speechRecognizer.error == nil {
                        Text("Listening...")
                            .font(sizePreset.font(12, weight: .medium))
                            .foregroundStyle(Colors.textActive)
                    }

                    if let parseError = parseError {
                        Text(parseError)
                            .font(sizePreset.font(12, weight: .medium))
                            .foregroundStyle(Colors.errorText)
                    }
                }
                .padding(.leading, sizePreset.scaled(20))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(speechRecognizer.isListening ? "Listening for time" : "Timer setup")
        .accessibilityValue(speechRecognizer.transcript.isEmpty ? "Waiting for input" : speechRecognizer.transcript)
    }
}
