import Foundation
import Speech
import AVFoundation
import Combine

class SubtitleGenerator: ObservableObject {
    @Published var isGenerating = false
    @Published var progress: Double = 0.0
    
    func generateSubtitles(for url: URL) {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            SFSpeechRecognizer.requestAuthorization { status in
                if status == .authorized {
                    self.generateSubtitles(for: url)
                }
            }
            return
        }
        
        isGenerating = true
        
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        
        recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                if result.isFinal {
                    self.saveSubtitles(result)
                    DispatchQueue.main.async {
                        self.isGenerating = false
                    }
                }
            } else if let error = error {
                print("Speech recognition error: \(error)")
                DispatchQueue.main.async {
                    self.isGenerating = false
                }
            }
        }
    }
    
    private func saveSubtitles(_ result: SFSpeechRecognitionResult) {
        // Convert result to SRT format
        var srtContent = ""
        for (index, segment) in result.bestTranscription.segments.enumerated() {
            let start = formatTime(segment.timestamp)
            let end = formatTime(segment.timestamp + segment.duration)
            srtContent += "\(index + 1)\n\(start) --> \(end)\n\(segment.substring)\n\n"
        }
        
        // Save to Documents
        let filename = "generated_subtitles.srt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filename)
            try? srtContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Saved subtitles to: \(fileURL.path)")
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 1000)
        return String(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, milliseconds)
    }
}
