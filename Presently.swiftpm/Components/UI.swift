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

            let size = size == .large ? AppFontSize.xl.rawValue : AppFontSize.lg.rawValue
            
            if (variant == .ghost) {
                HStack {
                    content
                }
                .font(.system(size: size, weight: .medium))
                .foregroundColor(AppColors.Primary500.color)
                .padding(.horizontal, horzPadding)
                .padding(.vertical, vertPadding)
            } else {
                HStack {
                    content
                }
                .font(.system(size: size, weight: .black))
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

// https://medium.com/@ganeshrajugalla/creating-beautiful-custom-loaders-with-swiftui-4ca99f3591b4
public struct LoadingSpinner: View {
    
    let size: CGFloat
    
    @State private var degree: Double = 270
    @State private var spinnerLength = 0.6
    
    public var body: some View {
        Circle()
            .trim(from: 0.0, to: spinnerLength)
            .stroke(
                LinearGradient(
                    colors: [AppColors.Primary500.color,
                             AppColors.Primary500.color],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round, lineJoin:.round)
            )
            .animation(
                Animation.easeIn(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: degree
            )
            .frame(width: size, height: size)
            .rotationEffect(Angle(degrees: Double(degree)))
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: degree
            )
            .onAppear{
                degree = 270 + 360
                spinnerLength = 0
            }
        //        Circle()
//            .trim(from: 0.0, to: spinnerLength)
//            .stroke(
//                LinearGradient(
//                    colors: [AppColors.Primary500.color, AppColors.Primary500.color],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                ),
//                style: StrokeStyle(
//                    lineWidth: 8.0,
//                    lineCap: .round,
//                    lineJoin: .round
//                )
//            )
//            .frame(width: 60, height: 60)
//            .rotationEffect(Angle(degrees: degree))
//            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: degree)
//            .onAppear {
//                withAnimation {
//                    degree = 630
//                    spinnerLength = 1.0
//                }
//            }
    }
    
//    public var body: some View {
//        Circle()
//            .trim(from: 0.0,to: spinnerLength)
//            .stroke(
//                LinearGradient(
//                    colors: [AppColors.Primary500.color,
//                             AppColors.Primary500.color],
//                    startPoint: .topLeading, endPoint: .bottomTrailing
//                ),
//                style: StrokeStyle(lineWidth: 8.0,lineCap: .round, lineJoin:.round)
//            )
//            .animation(Animation.easeIn(duration: 1.5).repeatForever(autoreverses: true))
//            .frame(width: 60,height: 60)
//            .rotationEffect(Angle(degrees: Double(degree)))
//            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
//            .onAppear{
//                degree = 270 + 360
//                spinnerLength = 0
//            }
//    }
}
