import SwiftUI

// Glass Button Component with Hover Effects
struct GlassButton: View {
    let systemImage: String
    let size: Font
    let action: () -> Void
    @State private var isHovered = false
    
    init(systemImage: String, size: Font, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(size)
                .foregroundStyle(.white)
                .shadow(color: isHovered ? .white.opacity(0.5) : .clear, radius: 8, x: 0, y: 0)
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
