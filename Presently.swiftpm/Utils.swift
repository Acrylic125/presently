import SwiftUI

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

public let HapticsImpactLight = UIImpactFeedbackGenerator(style: .light)
public let HapticsImpactMedium = UIImpactFeedbackGenerator(style: .medium)
