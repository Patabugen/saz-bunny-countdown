import SwiftUI

struct SazBunnyLayout<Content: View>: View {
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
                .frame(maxWidth: 144, maxHeight: .infinity, alignment: .bottom)
                .padding(.trailing, 16)
                .padding(.top, 30)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}
