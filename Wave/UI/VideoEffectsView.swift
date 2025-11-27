import SwiftUI

struct VideoEffectsView: View {
    @ObservedObject var player: MediaPlayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Video Effects")
                .font(.headline)
            
            Group {
                EffectSlider(label: "Brightness", value: $player.brightness, range: -1...1)
                EffectSlider(label: "Contrast", value: $player.contrast, range: 0...4)
                EffectSlider(label: "Saturation", value: $player.saturation, range: 0...4)
                EffectSlider(label: "Hue", value: $player.hue, range: -3.14...3.14)
                
                Toggle("AI Noise Reduction", isOn: $player.isNoiseReductionEnabled)
                Toggle("HDR Tone Mapping", isOn: $player.isToneMappingEnabled)
            }
            
            Divider()
            
            Button("Reset All") {
                player.resetEffects()
            }
        }
        .frame(width: 250)
    }
}

struct EffectSlider: View {
    let label: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range)
        }
    }
}
