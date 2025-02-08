import SwiftUI
import AVFoundation

func formatTime(_ milliseconds: Int) -> String {
    let seconds = milliseconds / 1000
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainingSeconds = seconds % 60
    
    var parts: [String] = []
    
    if hours > 0 {
        parts.append("\(hours)h")
    }
    if minutes > 0 {
        parts.append("\(minutes)min")
    }
    if remainingSeconds > 0 {
        parts.append("\(remainingSeconds)s")
    }
    
    return parts.isEmpty ? "0s" : parts.joined(separator: " ")
}

public func getSafeAreaInset() -> EdgeInsets {
    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    let _safeAreaInsets = scene?.windows.first?.safeAreaInsets ?? .zero
    
    let safeAreaInsets = EdgeInsets(
        top: _safeAreaInsets.top,
        leading: _safeAreaInsets.left,
        bottom: _safeAreaInsets.bottom,
        trailing: _safeAreaInsets.right
    )
    return safeAreaInsets
}

public struct Haptics {
    let light = UIImpactFeedbackGenerator(style: .light)
    let medium = UIImpactFeedbackGenerator(style: .medium)

    init() {
        light.prepare()
        medium.prepare()
        
        do {
            try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
        } catch {
            print("Failed to enable haptics during system recording")
            print(error)
        }
    }
}

//public let AppHaptics = Haptics()
