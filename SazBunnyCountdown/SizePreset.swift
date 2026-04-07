import SwiftUI

@MainActor
final class SizePreset: ObservableObject {
    private static let userDefaultsKey = "panelScale"

    static let baseWidth: CGFloat = 320
    static let baseHeight: CGFloat = 160
    static let aspectRatio: CGFloat = 2.0 // width:height = 2:1
    static let minScale: CGFloat = 0.5
    static let maxScale: CGFloat = 1.5

    static var minWidth: CGFloat { baseWidth * minScale }
    static var maxWidth: CGFloat { baseWidth * maxScale }
    static var minHeight: CGFloat { baseHeight * minScale }
    static var maxHeight: CGFloat { baseHeight * maxScale }

    private var _scale: CGFloat = 1.0
    var scale: CGFloat {
        get { _scale }
        set {
            let clamped = min(Self.maxScale, max(Self.minScale, newValue))
            guard clamped != _scale else { return }
            // Disable animations so the relayout is instant — prevents
            // focus rings and other chrome from flashing at intermediate sizes.
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                objectWillChange.send()
            }
            _scale = clamped
            UserDefaults.standard.set(clamped, forKey: Self.userDefaultsKey)
        }
    }

    init() {
        let saved = UserDefaults.standard.double(forKey: Self.userDefaultsKey)
        if saved > 0 {
            _scale = min(Self.maxScale, max(Self.minScale, CGFloat(saved)))
        } else {
            _scale = 1.0
        }
    }

    var windowWidth: CGFloat { Self.baseWidth * scale }
    var windowHeight: CGFloat { Self.baseHeight * scale }

    /// Corner radius with damped scaling to avoid looking too small at compact sizes.
    var cornerRadius: CGFloat {
        Colors.baseCornerRadius + (scale - 1.0) * 8
    }

    func font(_ size: CGFloat, weight: Font.Weight, design: Font.Design = .rounded) -> Font {
        .system(size: size * scale, weight: weight, design: design)
    }

    func scaled(_ value: CGFloat) -> CGFloat { value * scale }
}
