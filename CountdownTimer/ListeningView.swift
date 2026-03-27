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

            // Content
            if isSazBunny {
                sazBunnyContent
            } else {
                classicContent
            }

            // Top-right controls
            HStack(spacing: 6) {
                Menu {
                    ThemePickerMenu()
                } label: {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(t.shadow.opacity(0.4))
                }
                .menuStyle(.borderlessButton)
                .fixedSize()

                if isSazBunny {
                    sazCloseButton(isExpired: false)
                } else {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(t.shadow.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
        }
        .frame(width: WindowConstants.width, height: WindowConstants.height)
        .contextMenu { ThemePickerMenu() }
    }

    // MARK: - Saz Bunny Layout

    private var sazBunnyContent: some View {
        HStack(spacing: 0) {
            // Left side: text content (~65% width)
            VStack(alignment: .leading, spacing: 6) {
                if let error = speechRecognizer.error {
                    Text(error)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(t.errorText)
                } else if speechRecognizer.transcript.isEmpty {
                    Text("When should I finish?")
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundStyle(t.textPrimary)
                        .lineSpacing(4)

                    if speechRecognizer.isListening {
                        Text("Listening...")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(t.textActive ?? t.secondary)
                    }
                } else {
                    Text(speechRecognizer.transcript)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(t.textPrimary)
                }

                if let parseError = parseError {
                    Text(parseError)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(t.errorText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .padding(.trailing, 8)

            // Right side: bunny peeking from right edge, top-right anchored
            Image("SazBunny")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 76)
                .frame(maxWidth: 76, maxHeight: .infinity, alignment: .top)
                .offset(x: 8) // Push slightly off-edge for peeking effect
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 16)
        .clipped()
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

    // MARK: - Saz Close Button

    private func sazCloseButton(isExpired: Bool) -> some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(isExpired ? (t.closeButtonExpiredFg ?? t.shadow) : (t.closeButtonFg ?? t.shadow))
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(isExpired ? (t.closeButtonExpiredBg ?? t.background) : (t.closeButtonBg ?? t.background))
                )
        }
        .buttonStyle(.plain)
    }
}
