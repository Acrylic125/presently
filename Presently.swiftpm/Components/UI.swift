import SwiftUI

public enum AppButtonSize {
    case small, large
}

public enum AppButtonVariant {
    case base, ghost
}

public struct AppButton<Content: View>: View {
    
    let action: () -> Void
    
    let content: Content
    
    var size: AppButtonSize = .small
    var variant: AppButtonVariant = .base
    
    var horzPadding: CGFloat?
    var vertPadding: CGFloat?
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: action) {
            let horzPadding: CGFloat = (self.horzPadding) ?? (size == .large ? 20 : 16);
            let vertPadding: CGFloat = (self.vertPadding) ?? (size == .large ? 16 : 12);
            let borderRadius: CGFloat = size == .large ? 16 : 8;

            if (variant == .ghost) {
                HStack {
                    content
                }
                .font(.system(size: AppFontSize.xl.rawValue, weight: .medium))
                .foregroundColor(AppColors.Primary500.color)
                .padding(.horizontal, horzPadding)
                .padding(.vertical, vertPadding)
            } else {
                HStack {
                    content
                }
                .font(.system(size: AppFontSize.xl.rawValue, weight: .black))
                .foregroundColor(AppColors.Gray50.color)
                .padding(.horizontal, horzPadding)
                .padding(.vertical, vertPadding)
                .background(
                    RoundedRectangle(cornerRadius: borderRadius)
                        .fill(AppColors.Primary600.color)
                        .stroke(AppColors.Primary500.color, lineWidth: 1)
                )
            }
        }
    }
    
    public func size(_ v: AppButtonSize) -> AppButton {
         var button = self
         button.size = v
         return button
     }
     
     public func variant(_ v: AppButtonVariant) -> AppButton {
         var button = self
         button.variant = v
         return button
     }
    
    public func paddingHorz(_ v: CGFloat) -> AppButton {
        var button = self
        button.horzPadding = v
        return button
    }
    
    public func paddingVert(_ v: CGFloat) -> AppButton {
        var button = self
        button.vertPadding = v
        return button
    }

}
