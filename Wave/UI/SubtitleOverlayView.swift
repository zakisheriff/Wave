import SwiftUI

struct SubtitleOverlayView: View {
    let subtitle: AttributedString
    
    var body: some View {
        Text(subtitle)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.white)
            .padding(8)
            .background(Color.black.opacity(0.6))
            .cornerRadius(8)
            .padding(.bottom, 40)
            .shadow(radius: 2)
    }
}
