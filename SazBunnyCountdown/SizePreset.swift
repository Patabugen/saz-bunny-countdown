import SwiftUI

@MainActor
final class SizePreset: ObservableObject {
    private static let userDefaultsKey = "panelWidth"

    static let baseWidth: CGFloat = 320
    static let baseHeight: CGFloat = 160
    static let aspectRatio: CGFloat = 2.0 // width:height = 2:1
    static let minScale: CGFloat = 0.5
    static let maxScale: CGFloat = 1.5

    static var minWidth: CGFloat { baseWidth * minScale }
    static var maxWidth: CGFloat { baseWidth * maxScale }
    static var minHeight: CGFloat { baseHeight * minScale }
    static var maxHeight: CGFloat { baseHeight * maxScale }

    @Published var scale: CGFloat {
        didSet {
            let clamped = min(Self.maxScale, max(Self.minScale, scale))
            if clamped != scale { scale = clamped }
            UserDefaults.standard.set(clamped, forKey: Self.userDefaultsKey)
        }
    }

    init() {
        let saved = UserDefaults.standard.double(forKey: Self.userDefaultsKey)
        if saved > 0 {
            self.scale = min(Self.maxScale, max(Self.minScale, CGFloat(saved)))
        } else {
            self.scale = 1.0
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
