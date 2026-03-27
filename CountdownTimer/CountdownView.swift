import SwiftUI

@MainActor
struct CountdownView: View {
    @ObservedObject var viewModel: CountdownViewModel
    @ObservedObject var focusState: PanelFocusState
    @EnvironmentObject var themeManager: ThemeManager
    let onDismiss: () -> Void

    private var t: Theme { themeManager.active }
    private var isSazBunny: Bool { themeManager.activeStyle.usesBunnyImagery }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background
            RoundedRectangle(cornerRadius: t.cornerRadius)
                .fill(currentBackground)
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
                    sazCloseButton
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
        .animation(.easeInOut(duration: 0.3), value: viewModel.isFinished)
        .animation(.easeInOut(duration: 0.15), value: focusState.isFocused)
        .contextMenu { ThemePickerMenu() }
    }

    private var currentBackground: Color {
        if isSazBunny && viewModel.isFinished {
            return t.expiredBackground
        }
        return t.background
    }

    // MARK: - Saz Bunny Layout

    private var sazBunnyContent: some View {
        ZStack(alignment: .leading) {
            // Expired bunny peeking from left (behind digits)
            if viewModel.isFinished {
                Image("SazBunnyPeekExpired")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 76)
                    .scaleEffect(x: -1, y: 1) // Flip horizontally to peek from left
                    .offset(x: -8) // Push slightly off left edge
                    .accessibilityHidden(true)
                    .transition(.opacity)
            }

            // Main content row (always same position)
            HStack(alignment: .center) {
                // Left: large countdown digits
                VStack(spacing: 4) {
                    Text(viewModel.timeString)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(sazDigitColor)

                    HStack(spacing: 8) {
                        Button(action: onDismiss) {
                            Text("Quit")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(t.buttonText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(viewModel.isFinished ? t.buttonExpiredFill : t.buttonFill)
                                )
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(.return, modifiers: [])

                        if viewModel.isFinished {
                            Text("Time's up!")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(t.textExpiredLabel ?? t.finishedAlert)
                        } else if let target = viewModel.targetTimeString {
                            Text("until \(target)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(t.textSecondary)
                        }
                    }
                }
                .padding(.leading, 20)
                .layoutPriority(1)

                Spacer(minLength: 0)

                // Right column: bunny icon
                if viewModel.isFinished {
                    Color.clear
                        .frame(width: 28)
                } else {
                    Image("SazBunnySmall")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 144, maxHeight: .infinity, alignment: .bottom)
                        .padding(.trailing, 16)
                        .padding(.top, 30) // below close button / theme menu
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 0)
        }
        .clipped()
    }

    private var sazDigitColor: Color {
        if viewModel.isFinished {
            return t.textDigitsExpired ?? t.finishedAlert
        }
        return t.textDigits ?? t.accent
    }

    private var sazCloseButton: some View {
        let fg: Color = viewModel.isFinished
            ? (t.closeButtonExpiredFg ?? t.shadow)
            : (t.closeButtonFg ?? t.shadow)
        let bg: Color = viewModel.isFinished
            ? (t.closeButtonExpiredBg ?? t.background)
            : (t.closeButtonBg ?? t.background)

        return Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(fg)
                .frame(width: 22, height: 22)
                .background(Circle().fill(bg))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Classic (Clay) Layout

    private var classicContent: some View {
        VStack {
            Spacer()

            // Timer text
            if viewModel.isFinished {
                Text(viewModel.timeString)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(t.finishedAlert)
                    .shadow(color: t.outerShadowColor, radius: 2, x: 1, y: 2)
            } else {
                Text(viewModel.timeString)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(t.digitGradient)
                    .shadow(color: t.outerShadowColor, radius: 2, x: 1, y: 2)
            }

            Spacer()

            HStack {
                if let target = viewModel.targetTimeString {
                    Text("until \(target)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(t.textSecondary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Text("Quit")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(t.buttonText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(t.buttonFill)
                                .shadow(color: t.outerShadowColor, radius: 3, x: 1, y: 2)
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
