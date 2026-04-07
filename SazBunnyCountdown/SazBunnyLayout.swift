import SwiftUI

struct SazBunnyLayout<Content: View>: View {
    @EnvironmentObject var sizePreset: SizePreset
    let bunnyImage: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .center) {
            content
                .layoutPriority(1)

            Spacer(minLength: 0)

            Image(bunnyImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: sizePreset.scaled(144), maxHeight: .infinity, alignment: .bottom)
                .padding(.trailing, sizePreset.scaled(16))
                .padding(.top, sizePreset.scaled(30))
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}
