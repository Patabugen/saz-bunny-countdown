import SwiftUI

@MainActor
struct CountdownView: View {
    @ObservedObject var viewModel: CountdownViewModel
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            VStack(spacing: 2) {
                Text(viewModel.timeString)
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundColor(viewModel.isFinished ? .red : .primary)

                if let target = viewModel.targetTimeString {
                    Text("until \(target)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Text("Esc to quit, Space to restart")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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
