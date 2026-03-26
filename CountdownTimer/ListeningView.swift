import SwiftUI

struct ListeningView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            VStack(spacing: 6) {
                if let error = speechRecognizer.error {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else if speechRecognizer.transcript.isEmpty {
                    Text("When should I finish?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    if speechRecognizer.isListening {
                        Text("Listening...")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(speechRecognizer.transcript)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 12)

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(8)
        }
        .frame(width: 240, height: 80)
    }
}
