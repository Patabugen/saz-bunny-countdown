import SwiftUI

@MainActor
struct CountdownView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @ObservedObject var focusState: PanelFocusState
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            focusState.isFocused ? Color.accentColor.opacity(0.8) : Color.white.opacity(0.2),
                            lineWidth: focusState.isFocused ? 2 : 1
                        )
                )

            VStack(spacing: 4) {
                Text(viewModel.timeString)
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundColor(viewModel.isFinished ? .red : .primary)

                if let target = viewModel.targetTimeString {
                    Text("until \(target)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Button(action: onDismiss) {
                    Text("Quit")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.8))
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return, modifiers: [])
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
        .frame(width: 240, height: 100)
        .animation(.easeInOut(duration: 0.15), value: focusState.isFocused)
    }
}
