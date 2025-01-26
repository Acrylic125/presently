import SwiftUI
import AVFoundation

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
