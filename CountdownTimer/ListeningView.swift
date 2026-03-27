import SwiftUI

@MainActor
struct ListeningView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @ObservedObject var focusState: PanelFocusState
    @EnvironmentObject var themeManager: ThemeManager
    var parseError: String?
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

            VStack(spacing: 6) {
                if let error = speechRecognizer.error {
                    Text(error)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(t.errorText)
                        .multilineTextAlignment(.center)
                } else if speechRecognizer.transcript.isEmpty {
                    Text("When should I finish?")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(t.textPrimary)

                    if speechRecognizer.isListening {
                        Text("Listening...")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(t.secondary)
                    }
                } else {
                    Text(speechRecognizer.transcript)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(t.textPrimary)
                }

                if let parseError = parseError {
                    Text(parseError)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(t.errorText)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)

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
        .contextMenu { ThemePickerMenu() }
    }
}
