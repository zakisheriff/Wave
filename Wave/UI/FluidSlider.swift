import SwiftUI

// Modern macOS Tahoe-style Fluid Slider
struct FluidSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var onEditingChanged: ((Bool) -> Void)? = nil
    
    @State private var isDragging = false
    @State private var isHovering = false
    @State private var dragValue: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track with gradient
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.25)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: isHovering || isDragging ? 8 : 6)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                
                // Progress track with vibrant gradient
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.white.opacity(0.9)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * CGFloat((isDragging ? dragValue : value) / (range.upperBound - range.lowerBound)),
                        height: isHovering || isDragging ? 8 : 6
                    )
                    .shadow(color: .white.opacity(0.5), radius: isHovering || isDragging ? 4 : 2)
                
                // Animated thumb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white,
                                Color.white.opacity(0.95)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 10
                        )
                    )
                    .frame(
                        width: isDragging ? 20 : isHovering ? 16 : 0,
                        height: isDragging ? 20 : isHovering ? 16 : 0
                    )
                    .shadow(color: .black.opacity(0.3), radius: isDragging ? 6 : 3, y: isDragging ? 3 : 2)
                    .shadow(color: .white.opacity(0.5), radius: isDragging ? 8 : 4)
                    .offset(
                        x: geometry.size.width * CGFloat((isDragging ? dragValue : value) / (range.upperBound - range.lowerBound)) - (isDragging ? 10 : isHovering ? 8 : 0)
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
            }
            .frame(height: 24)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            withAnimation(.spring(response: 0.2)) {
                                isDragging = true
                            }
                            onEditingChanged?(true)
                        }
                        let newValue = Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                        let clampedValue = max(range.lowerBound, min(range.upperBound, newValue))
                        dragValue = clampedValue
                        value = clampedValue
                    }
                    .onEnded { gesture in
                        let newValue = Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound) + range.lowerBound
                        let clampedValue = max(range.lowerBound, min(range.upperBound, newValue))
                        value = clampedValue
                        
                        withAnimation(.spring(response: 0.3)) {
                            isDragging = false
                        }
                        onEditingChanged?(false)
                    }
            )
            .onHover { hovering in
                withAnimation(.spring(response: 0.2)) {
                    isHovering = hovering
                }
            }
        }
    }
}
