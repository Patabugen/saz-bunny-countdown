import SwiftUI

@MainActor
struct ListeningView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @ObservedObject var focusState: PanelFocusState
    var parseError: String?
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
                if let error = speechRecognizer.error {
                    Text(error)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(ClayTheme.errorText)
                        .multilineTextAlignment(.center)
                } else if speechRecognizer.transcript.isEmpty {
                    Text("When should I finish?")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(ClayTheme.textPrimary)

                    if speechRecognizer.isListening {
                        Text("Listening...")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(ClayTheme.sage)
                    }
                } else {
                    Text(speechRecognizer.transcript)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(ClayTheme.textPrimary)
                }

                if let parseError = parseError {
                    Text(parseError)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(ClayTheme.errorText)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ClayTheme.shadow.opacity(0.4))
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .frame(width: ClayTheme.windowWidth, height: ClayTheme.windowHeight)
    }
}
